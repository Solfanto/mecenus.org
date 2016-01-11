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
  validates :project_id, uniqueness: { scope: :user_id }

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
      amount: Currency::ZERO_DECIMAL_CURRENCIES.include?(self.currency) ? self.amount.to_i : (self.amount * 100).to_i,
      interval: self.recurrence_type == "yearly" ? "year" : "month",
      name: "Donation for #{self.project.title}",
      currency: self.currency.downcase,
      id: "donation_for_#{self.project.name}_from_user_#{self.user_id}",
      metadata: {
        user_id: self.user_id
      }
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

    if Rails.application.config.trial_end == 'now'
      trial_end = 'now'
    elsif project.processing_day > Time.now.utc.day
      trial_end = Time.now.utc.change(day: project.processing_day).beginning_of_day.to_i
    else
      trial_end = (Time.now.utc + 1.month).change(day: project.processing_day).beginning_of_day.to_i
    end
    self.subscription = customer.subscriptions.create(
      plan: self.plan["id"], 
      trial_end: trial_end, 
      metadata: {
        donation_id: self.id,
        user_id: self.user_id
      }
    )
    raise DonationError, "Subscription couldn't be created" if self.subscription.nil?

    self.stripe_plan_id = self.plan["id"]
    self.stripe_subscription_id = self.subscription["id"]
    self.save!
  rescue Stripe::InvalidRequestError => error
    if error.message == "No such customer: #{self.user.stripe_customer_id}"
      self.user.stripe_customer_id = nil
      self.user.save
    else
      raise DonationError, "Subscription couldn't be started: #{error.message}"
    end
  end
  after_commit :start_subscription, on: :create

  def update_supscription
    return if self.user.stripe_customer_id.nil?
    return if self.previous_changes["amount"].nil?

    begin
      customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
      customer.subscriptions.retrieve(self.stripe_subscription_id)&.delete if self.stripe_subscription_id
    rescue Stripe::InvalidRequestError => error
      self.stripe_subscription_id = nil
    end

    begin
      old_plan = Stripe::Plan.retrieve(self.stripe_plan_id) if self.stripe_plan_id
      old_plan&.delete
    rescue Stripe::InvalidRequestError => error
      self.stripe_plan_id = nil
    end

    create_stripe_plan!
    raise DonationError, "Plan couldn't be created" if self.plan.nil?

    if Rails.application.config.trial_end == 'now'
      trial_end = 'now'
    elsif project.processing_day > Time.now.utc.day
      trial_end = Time.now.utc.change(day: project.processing_day).beginning_of_day.to_i
    else
      trial_end = (Time.now.utc + 1.month).change(day: project.processing_day).beginning_of_day.to_i
    end
    self.subscription = customer.subscriptions.create(
      plan: self.plan["id"], 
      trial_end: trial_end, 
      metadata: {
        donation_id: self.id,
        user_id: self.user_id
      }
    )
    raise DonationError, "Subscription couldn't be created" if subscription.nil?

    self.stripe_plan_id = self.plan["id"]
    self.stripe_subscription_id = self.subscription["id"]
    self.save!
  rescue Stripe::InvalidRequestError => error
    raise DonationError, "Subscription couldn't be updated: #{error.message}"
  end
  after_commit :update_supscription, on: :update

  def stop_subscription
    return if self.user.stripe_customer_id.nil?
    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    customer.subscriptions.retrieve(self.stripe_subscription_id)&.delete if self.stripe_subscription_id

    old_plan = Stripe::Plan.retrieve(self.stripe_plan_id) if self.stripe_plan_id
    old_plan&.delete
  rescue Stripe::InvalidRequestError => error
    if error.message == "No such customer: #{self.user.stripe_customer_id}"
      self.user.stripe_customer_id = nil
      self.user.save
    end
  end
  after_commit :stop_subscription, on: :destroy
end
