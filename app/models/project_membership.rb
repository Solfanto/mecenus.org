class ProjectMembership < ApplicationRecord
  enum role: [:admin, :member]

  belongs_to :user
  belongs_to :project
end
