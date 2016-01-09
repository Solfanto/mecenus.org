class ChangeAmountTypeFloatToDecimal < ActiveRecord::Migration
  def up
    change_column :donation_records, :amount, :decimal, precision: 10, scale: 2,  default: 0.0
    change_column :donation_records, :balance, :decimal, precision: 10, scale: 2,  default: 0.0
    change_column :donations, :amount, :decimal, precision: 10, scale: 2, default: 0.0
    change_column :payments, :amount, :decimal, precision: 10, scale: 2, default: 0.0
    change_column :projects, :donation_amount_per_month, :decimal, precision: 10, scale: 2, default: 0.0
    change_column :users, :balance, :decimal, precision: 10, scale: 2, default: 0.0
  end

  def down
    change_column :donation_records, :amount, :float, default: 0.0
    change_column :donation_records, :balance, :float, default: 0.0
    change_column :donations, :amount, :float, default: 0.0
    change_column :payments, :amount, :float, default: 0.0
    change_column :projects, :donation_amount_per_month, :float, default: 0.0
    change_column :users, :balance, :float, default: 0.0
  end
end
