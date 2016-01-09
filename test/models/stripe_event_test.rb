require 'test_helper'

class StripeEventTest < ActiveSupport::TestCase
  test "stripe connects" do
    begin
      Stripe::Event.all(limit: 3)
    rescue Stripe::AuthenticationError => e
      assert false, "Stripe can't connect: #{e.message}"
    else
      assert true
    end
  end
end
