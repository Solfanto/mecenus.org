# Donation is a subscription
# Its recurrence type can be monthly/yearly/per_major_release/per_minor_release

class Donation < ActiveRecord::Base
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

  def create_stripe_plan
    Stripe::Plan.create(
      amount: self.amount,
      interval: self.recurrence_type == "yearly" ? "year" : "month",
      name: "Donations for #{self.project.title}",
      currency: self.currency.downcase,
      id: "donation_for_#{self.project.name}_from_user_#{self.user_id}_"
    )
  end

  def start_subscription
    return if self.user.stripe_customer_id.nil?
    plan = create_stripe_plan

    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    subscription = customer.subscriptions.create(plan: plan["id"])

    self.stripe_plan_id = plan["id"]
    self.stripe_subscription_id = subscription["id"]
    self.save!
  end
  after_commit :start_subscription, on: :create

  def update_supscription
    return if self.user.stripe_customer_id.nil?
    return unless self.amount_changed?

    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    customer.subscriptions.retrieve(self.stripe_subscription_id).delete

    old_plan = Stripe::Plan.retrieve(self.stripe_plan_id)
    old_plan.delete

    plan = create_stripe_plan
    customer.subscriptions.create(plan: plan["id"])

    self.stripe_plan_id = plan["id"]
    self.stripe_subscription_id = subscription["id"]
    self.save!
  end
  after_commit :update_supscription, on: :update

  def stop_subscription
    return if self.user.stripe_customer_id.nil?
    customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    customer.subscriptions.retrieve(self.stripe_subscription_id).delete

    old_plan = Stripe::Plan.retrieve(self.stripe_plan_id)
    old_plan.delete
  end
  after_commit :stop_subscription, on: :destroy
end
