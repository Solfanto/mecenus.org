class AddBankAccountInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :currency, :string
  end
end
