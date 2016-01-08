class AddVerifiedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :verified, :boolean, default: false
    add_column :projects, :verified_at, :datetime
    add_reference :projects, :verified_by, index: true
  end
end
