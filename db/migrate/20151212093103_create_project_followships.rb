class CreateProjectFollowships < ActiveRecord::Migration
  def change
    create_table :project_followships do |t|
      t.references :project
      t.references :user

      t.boolean :receive_notifications, defaut: true
      t.timestamps null: false
    end
  end
end
