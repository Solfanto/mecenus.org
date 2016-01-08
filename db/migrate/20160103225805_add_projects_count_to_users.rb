class AddProjectsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :created_projects_count, :integer, default: 0
  end
end
