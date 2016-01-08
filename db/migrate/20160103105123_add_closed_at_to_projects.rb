class AddClosedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :closed_at, :datetime
  end
end
