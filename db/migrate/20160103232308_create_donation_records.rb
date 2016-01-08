class CreateDonationRecords < ActiveRecord::Migration
  def change
    create_table :donation_records do |t|
      t.references :user
      t.references :project
      t.date :date
      t.float :amount, default: 0
      t.string :currency
      t.float :balance, default: 0

      t.timestamps null: false
    end
  end
end
