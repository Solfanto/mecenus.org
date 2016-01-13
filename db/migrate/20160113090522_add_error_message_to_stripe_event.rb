class AddErrorMessageToStripeEvent < ActiveRecord::Migration
  def change
    add_column :stripe_events, :error_message, :text
  end
end
