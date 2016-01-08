class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user
      t.references :project

      t.timestamps null: false
    end
  end
end
