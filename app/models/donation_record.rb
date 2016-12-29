# These are the records of donations as received by the maintainer
# They are aggregations of payments

class DonationRecord < ApplicationRecord
  belongs_to :user # the receiver
  belongs_to :project

  has_many :payments

  def processed?
    self.processed_at != nil
  end

  def aggregated?
    self.aggregated_at != nil
  end

  def process_payment_to_maintainer
    if self.aggregated? && !processed?
      begin
        bank_account = self.user.fetch_bank_information
        transfer = Stripe::Transfer.create(
          amount: Currency::ZERO_DECIMAL_CURRENCIES.include?(self.project.currency) ? self.amount.to_i : (self.amount * 100).to_i,
          currency: self.project.currency.downcase,
          destination: bank_account["id"],
          description: "Donations of #{self.processed_at.strftime("%Y/%m/%d")} for #{self.project.title}"
        )
      rescue => e
      else
        self.stripe_transfer_id = transfer["id"]
        self.processed_at = Time.now
        self.save!
      end
    end
  end
  after_commit :process_payment_to_maintainer, on: [:create, :update]
end
