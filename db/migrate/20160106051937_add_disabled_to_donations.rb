class AddDisabledToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :enabled, :boolean, default: true
  end
end
