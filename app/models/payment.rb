# These are the payments done by the sponsors
class PaymentError < StandardError; end

class Payment < ActiveRecord::Base
  include Stripe::Callbacks
  attr_accessor :will_be_processed_at

  belongs_to :user
  belongs_to :project
  belongs_to :donation
  belongs_to :donation_record

  scope :processed, -> {where("processed_at IS NOT NULL")}
  scope :not_processed, -> {where("processed_at IS NULL")}

  # after confirmation from Stripe that a payment has been done
  # 1. check what is the related donation
  # 2. make a new payment
  # 3. add the amount to the related donation record
  after_invoice_payment_succeeded! do |invoice, event|
    invoice_hash = invoice.as_json
    event_hash = event.as_json
    event = StripeEvent.record_event(invoice, event)
    begin
      Payment.process_payment(invoice_hash.fetch("lines", {}).
        fetch("data", []).first, invoice_hash, event_hash, :succeeded
      )
    rescue => e
      event.error_message = e.message
      event.save
    end
  end

  after_invoice_payment_failed! do |invoice, event|
    invoice_hash = invoice.as_json
    event_hash = event.as_json
    event = StripeEvent.record_event(invoice, event)
    begin
      Payment.process_payment(invoice_hash.fetch("lines", {}).
        fetch("data", []).first, invoice_hash, event_hash, :failed
      )
    rescue => e
      event.error_message = e.message
      event.save
    end
  end

  def self.process_payment(subscription, invoice, event, state)
    user = User.find_by(stripe_customer_id: invoice["customer"])
    donation = Donation.find(subscription["metadata"]["donation_id"])
    project = donation.project
    amount = BigDecimal.new(subscription["amount"]) / (Currency::ZERO_DECIMAL_CURRENCIES.include?(subscription["currency"]) ? 1 : 100)

    record = DonationRecord.where(
      project_id: project.id, 
      date: Time.now.utc.change(day: project.processing_day).beginning_of_day
    ).first_or_initialize
    if record.new_record?
      record.user_id = project.user_id
      record.currency = project.currency
      record.balance = project.user.balance
      record.expected_donations_count = project.donations.enabled.count
    end
    raise PaymentError, "Currency doesn't match" if subscription["currency"] != project.currency.downcase
    if state == :succeeded
      record.amount += amount
      record.balance += amount
    end
    record.save!

    payment = Payment.new
    payment.user_id = user.id
    payment.project_id = project.id
    payment.donation_id = donation.id
    payment.amount = amount
    payment.state = state.to_s
    payment.processed_at = DateTime.strptime(event["created"].to_s, '%s')
    payment.save!

    record.payments << payment

    record.aggregated_at = Time.now if record.expected_donations_count == record.payments.count
    record.save!
  end

end
