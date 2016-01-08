class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :user
      t.references :project
      t.references :donation
      t.references :donation_record

      t.float :amount, default: 0
      t.string :currency, default: 'USD'
      t.datetime :processed_at

      t.timestamps null: false
    end
  end
end
