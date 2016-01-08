class AddLicenseUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :license_url, :datetime
  end
end
