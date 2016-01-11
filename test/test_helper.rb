ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def add_testing_payment_to_user(user)
    user.add_payment_method(provider: :stripe, card: {
      exp_month: "12",
      exp_year: "24",
      number: "4242424242424242",
      cvc: "123",
      name: "#{user.email}",
      address_city: nil,
      address_country: nil,
      address_line1: nil,
      address_line2: nil,
      address_state: nil,
      address_zip: nil
    })
  end
end
