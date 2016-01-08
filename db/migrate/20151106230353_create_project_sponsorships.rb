class CreateProjectSponsorships < ActiveRecord::Migration
  def change
    create_table :project_sponsorships do |t|
      t.references :project
      t.references :user
      t.timestamps null: false
    end
  end
end
