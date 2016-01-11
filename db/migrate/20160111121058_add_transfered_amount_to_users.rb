class AddTransferedAmountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :transfered_amount, :decimal, precision: 15, scale: 2,  default: 0.0
  end
end
