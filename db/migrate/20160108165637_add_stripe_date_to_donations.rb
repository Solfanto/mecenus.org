class AddStripeDateToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :stripe_plan_id, :string
    add_column :donations, :stripe_subscription_id, :string
  end
end
