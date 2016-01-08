class AddReccurenceTypeToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :recurrence_type, :string, default: "monthly"
    add_column :donations, :processing_day, :integer, default: 1

    add_column :projects, :processing_day, :integer, default: 1

    add_column :donation_records, :processed_at, :datetime
  end
end
