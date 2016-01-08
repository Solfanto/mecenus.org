class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.references :user
      t.boolean :anonymous, default: false
      t.references :project
      t.float :amount, default: 0
      t.timestamps null: false
    end
  end
end
