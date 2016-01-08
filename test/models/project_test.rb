require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "Project fixtures are valid" do
    project = projects(:mecenus_org)
    assert project.valid?, project.errors.full_messages.to_sentence
    assert project.user == users(:mecenus), "Project user is incorrect: #{project.user_id}"
  end
end
