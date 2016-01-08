class CreateStripeEvents < ActiveRecord::Migration
  def change
    create_table :stripe_events do |t|
      t.string :event_id
      t.string :object_type
      t.string :object_id
      t.string :object_description
      t.text :json
      t.timestamps null: false
    end
  end
end
