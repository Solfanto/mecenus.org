require 'test_helper'

class ProjectFollowshipTest < ActiveSupport::TestCase
  test "User can follow projects" do
    project = projects(:mecenus_org)
    sponsor = users(:sponsor)

    assert !sponsor.follow?(project), "User already follows the project"
    sponsor.follow(project)
    assert sponsor.follow?(project), "User doesn't follow the project"
    sponsor.unfollow(project)
    assert !sponsor.follow?(project), "User still follows the project"
  end
end
