class CreateProjectMemberships < ActiveRecord::Migration
  def change
    create_table :project_memberships do |t|
      t.references :project
      t.references :user
      t.integer :role, default: :member
      t.timestamps null: false
    end
  end
end
