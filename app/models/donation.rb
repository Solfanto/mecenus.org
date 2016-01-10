# Donation is a subscription
# Its recurrence type can be monthly/yearly/per_major_release/per_minor_release
class DonationError < StandardError; end

class Donation < ActiveRecord::Base
  attr_accessor :plan, :subscription

  belongs_to :user
  belongs_to :project, counter_cache: true
  has_many :payments

  validates :amount, numericality: { greater_than: 0 }
  validates :processing_day, numericality: { greater_than: 0, less_than: 29 }

  scope :enabled, -> {where(enabled: true)}

  def update_donation_amount_per_month
    self.project.update_donation_amount_per_month
  end
  after_commit :update_donation_amount_per_month, on: [:create, :update, :destroy]

  def currency
    self.project.currency
  end

  def create_stripe_plan!
    self.plan = Stripe::Plan.create(
      amount: self.amount.to_i,
      interval: self.recurrence_type == "yearly" ? "year" : "month",
      name: "Donation for #{self.project.title}",
      currency: self.currency.downcase,
      id: "donation_for_#{self.project.name}_from_user_#{self.user_id}"
    )
  rescue Stripe::InvalidRequestError => error
    if error.message == "Plan already exists."
      self.plan = Stripe::Plan.retrieve("donation_for_#{self.project.name}_from_user_#{self.user_id}")
    else
      raise error
    end
  end

  def start_subscription
    return if self.user.stripe_customer_id.nil?
    return unless self.stripe_plan_id.nil? && self.stripe_subscription_id.nil?
    create_stripe_plan!
    raise DonationError, "Plan couldn't be created" if self.plan.nil?

    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    self.subscription = customer.subscriptions.create(plan: self.plan["id"])
    raise DonationError, "Subscription couldn't be created" if self.subscription.nil?

    self.stripe_plan_id = self.plan["id"]
    self.stripe_subscription_id = self.subscription["id"]
    self.save!
  rescue Stripe::InvalidRequestError => e
    raise DonationError, "Subscription couldn't be started: #{e.message}"
  end
  after_commit :start_subscription, on: :create

  def update_supscription
    return if self.user.stripe_customer_id.nil?
    return if self.previous_changes["amount"].nil?

    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    customer.subscriptions.retrieve(self.stripe_subscription_id)&.delete if self.stripe_subscription_id

    old_plan = Stripe::Plan.retrieve(self.stripe_plan_id) if self.stripe_plan_id
    old_plan&.delete

    create_stripe_plan!
    raise DonationError, "Plan couldn't be created" if self.plan.nil?
    self.subscription = customer.subscriptions.create(plan: self.plan["id"])
    raise DonationError, "Subscription couldn't be created" if subscription.nil?

    self.stripe_plan_id = self.plan["id"]
    self.stripe_subscription_id = self.subscription["id"]
    self.save!
  rescue Stripe::InvalidRequestError => e
    raise DonationError, "Subscription couldn't be updated: #{e.message}"
  end
  after_commit :update_supscription, on: :update

  def stop_subscription
    return if self.user.stripe_customer_id.nil?
    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    customer.subscriptions.retrieve(self.stripe_subscription_id)&.delete if self.stripe_subscription_id

    old_plan = Stripe::Plan.retrieve(self.stripe_plan_id) if self.stripe_plan_id
    old_plan&.delete
  end
  after_commit :stop_subscription, on: :destroy
end
