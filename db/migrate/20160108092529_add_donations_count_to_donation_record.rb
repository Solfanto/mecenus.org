class AddDonationsCountToDonationRecord < ActiveRecord::Migration
  def change
    add_column :donation_records, :expected_donations_count, :integer, default: 0
    add_column :donation_records, :received_donations_count, :integer, default: 0
    add_column :donation_records, :aggregated_at, :datetime
    add_column :donation_records, :stripe_transfer_id, :string
    add_column :donation_records, :state, :string
  end
end
