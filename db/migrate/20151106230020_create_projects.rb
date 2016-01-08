class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :user
      t.string :name
      t.string :title
      t.string :summary
      t.text :description
      t.string :url
      t.string :repo_url

      t.float :donation_amount_per_month, default: 0
      t.integer :project_sponsorships_count, default: 0
      t.integer :posts_count, default: 0
      t.timestamps null: false
    end
  end
end
