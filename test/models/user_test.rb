require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "User fixtures are valid" do
    maintainer = users(:mecenus)
    assert maintainer.valid?, maintainer.errors.full_messages.to_sentence

    sponsor = users(:sponsor)
    assert sponsor.valid?, sponsor.errors.full_messages.to_sentence
  end
end
