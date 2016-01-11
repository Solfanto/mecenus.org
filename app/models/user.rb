class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :created_projects, class_name: 'Project'
  has_many :project_memberships
  has_many :projects, through: :project_memberships, class_name: 'Project'
  has_many :donations
  has_many :payments

  has_many :project_followships
  has_many :followed_projects, through: :project_followships, source: :project

  has_many :donation_records

  attr_accessor :bank_account_number, :bank_routing_number, :bank_holder_name

  validate :new_project_required_info
  attr_accessor :creating_new_project

  def new_project_required_info
    if self.creating_new_project || self.created_projects_count > 0
      valid = true
      self.errors.add(:display_name, "is blank.") && valid = false if self.display_name.blank?
      self.errors.add(:bio, "is blank.") && valid = false if self.bio.blank?
      self.errors.add(:location, "is blank.") && valid = false if self.location.blank?
      return valid
    end
    return true
  end

  def format_twitter_username
    self.twitter_username = self.twitter_username&.gsub(/((https?\:\/\/)?(www\.|m\.)?twitter.com\/|@)?([a-zA-Z0-9\.]+)/, '\4')
  end
  before_save :format_twitter_username

  def format_facebook_username
    self.facebook_username = self.facebook_username&.gsub(/((https?\:\/\/)?(www\.|m\.)?facebook.com\/)?([a-zA-Z0-9\.]+)/, '\4')
  end
  before_save :format_facebook_username

  def follow?(project)
    self.followed_projects.include?(project)
  end

  # DEVISE

  # instead of deleting, indicate the user requested a delete & timestamp it  
  def soft_delete  
    update_attribute(:deleted_at, Time.current)
    self.created_projects.each do |project|
      project.close
    end
  end  

  # ensure user account is active  
  def active_for_authentication?  
    super && !deleted_at  
  end

  def after_database_authentication
    # restore account after sign in
    update_attribute(:deleted_at, nil)
  end

  # BANK TRANSFER

  def fetch_bank_information
    stripe_account = Stripe::Account.retrieve(self.stripe_account_id)
    existing_bank_accounts = stripe_account.external_accounts.all(object: "bank_account")
    existing_bank_accounts["data"].last
  end

  def update_bank_information(country:, currency:, account_number:, routing_number: nil, account_holder_type: "individual", name: nil)
    existing_bank_accounts = {"data" => []}

    if self.stripe_account_id.nil?
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      stripe_account = Stripe::Account.create(
        {
          country: country,
          managed: true,
          email: self.email
        }
      )
    else
      stripe_account = Stripe::Account.retrieve(self.stripe_account_id)
      existing_bank_accounts = stripe_account.external_accounts.all(object: "bank_account")
    end

    raise "No stripe account found" if stripe_account.nil?

    stripe_account.external_accounts.create({
      external_account: {
        object: "bank_account",
        account_number: account_number,
        country: country,
        currency: currency,
        account_holder_type: account_holder_type, # individual or company
        name: name,
        routing_number: routing_number
      },
      default_for_currency: true
    })

    for id in existing_bank_accounts["data"].map {|a| a["id"]}
      stripe_account.external_accounts.retrieve(id).delete
    end

    self.stripe_account_id = stripe_account["id"]
    self.save
  end

  # PAYMENT

  def add_payment_method(provider:, card:)
    if provider == :stripe
      add_payment_method_with_stripe(card: card)
    elsif provider == :paypal
      add_payment_method_with_paypal(card: card)
    end
  end

  def add_payment_method_with_stripe(card:)
    source = {
      object: "card",
      exp_month: card[:exp_month],
      exp_year: card[:exp_year],
      number: card[:number],
      cvc: card[:cvc],
      name: card[:name],
      address_city: card[:address_city],
      address_country: card[:address_country],
      address_line1: card[:address_line1],
      address_line2: card[:address_line2],
      address_state: card[:address_state],
      address_zip: card[:address_zip]
    }
    if self.stripe_customer_id
      customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      customer.sources.create({source: source})
    else
      customer = Stripe::Customer.create(
        description: "Customer for #{self.email}",
        source: source
      )
      self.stripe_customer_id = customer["id"]
      self.save
    end
  rescue Stripe::InvalidRequestError => error
    if error.message == "No such customer: #{self.stripe_customer_id}"
      self.stripe_customer_id = nil
      self.save
      add_payment_method_with_stripe(card: card)
    end
  end

  def add_payment_method_with_paypal(card:)
    # TODO:
  end

  def create_subscription(project:, amount:, provider:)
    if provider == :stripe
      create_subscription_with_stripe(project: project, amount: amount)
    elsif provider == :paypal
      create_subscription_with_paypal(project: project, amount: amount)
    end
  end

  def create_subscription_with_stripe(project:, amount:)
    customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    customer.subscriptions.create({plan: "monthly_donation_to_#{project}_#{amount}"})
  end

  def create_subscription_with_paypal(project:, amount:)
    # TODO:
  end

  def current_card
    return nil if self.stripe_customer_id.nil?
    @current_card ||= Stripe::Customer.retrieve(self.stripe_customer_id).sources.all(limit: 1, object: "card")["data"].last
  rescue Stripe::InvalidRequestError => error
    if error.message == "No such customer: #{self.stripe_customer_id}"
      self.stripe_customer_id = nil
      self.save
      @current_card = nil
    end
  ensure
    @current_card
  end

  # provide a custom message for a deleted account   
  # def inactive_message
  #   !deleted_at ? super : :deleted_account  
  # end  

  def follow(project)
    self.followed_projects << project unless self.followed_projects.include?(project)
  end

  def unfollow(project)
    self.followed_projects.delete(project)
  end

  def donate_to(project, amount)
    if self.stripe_customer_id.nil?
      self.errors.add("Current credit card", "is not valid.")
      return false
    end
    donation = self.donations.where(project_id: project.id).first
    donation ||= self.donations.build(project_id: project.id)
    donation.amount = amount
    donation.save
  end

  def cancel_donation_for(project)
    donation = self.donations.where(project_id: project.id).first
    donation&.destroy
  end
end
