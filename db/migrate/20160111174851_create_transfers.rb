class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.references :user
      t.decimal :amount, precision: 10, scale: 2,  default: 0.0
      t.string :currency, default: 'USD'
      t.datetime :processed_at
      t.timestamps null: false
    end
  end
end
