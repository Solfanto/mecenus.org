class AddContentToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :name, :string
    add_column :posts, :title, :string
    add_column :posts, :content, :text
    add_column :posts, :published_at, :datetime
    add_column :posts, :permalink, :string
  end
end
