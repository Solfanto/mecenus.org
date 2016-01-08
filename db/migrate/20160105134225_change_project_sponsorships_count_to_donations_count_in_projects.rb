class ChangeProjectSponsorshipsCountToDonationsCountInProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :project_sponsorships_count, :donations_count

    drop_table :project_sponsorships
  end
end
