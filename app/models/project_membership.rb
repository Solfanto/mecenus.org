class ProjectMembership < ActiveRecord::Base
  enum role: [:admin, :member]

  belongs_to :user
  belongs_to :project
end
