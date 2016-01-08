class AddInfoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :latest_version, :string
    add_column :projects, :readme_url, :string
    add_column :projects, :changelog_url, :string
    add_column :projects, :language, :string
    add_column :projects, :license, :string

    add_column :projects, :latest_update_at, :datetime
  end
end
