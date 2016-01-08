class AddFeaturedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :featured_from, :datetime
    add_column :projects, :featured_until, :datetime
  end
end
