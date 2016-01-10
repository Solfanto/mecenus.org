require 'test_helper'

class DonationTest < ActiveSupport::TestCase
  test "donation is made" do
    sponsor = users(:sponsor)
    sponsor.add_payment_method(provider: :stripe, card: {
      exp_month: "12",
      exp_year: "24",
      number: "4242424242424242",
      cvc: "123",
      name: "Mr Sponsor",
      address_city: nil,
      address_country: nil,
      address_line1: nil,
      address_line2: nil,
      address_state: nil,
      address_zip: nil
    })
    assert !sponsor.stripe_customer_id.nil?, "User has no stripe customer id"

    project = projects(:mecenus_org)

    amount = BigDecimal.new("7.5")
    sponsor.donate_to(project, amount)
    donation = sponsor.donations.find_by(project_id: project.id)

    tmp_stripe_plan_id = donation.stripe_plan_id
    tmp_stripe_subscription_id = donation.stripe_subscription_id

    assert !donation.stripe_plan_id.nil?, "Stripe Plan ID is not assigned"
    assert !donation.stripe_subscription_id.nil?, "Stripe Subscription ID is not assigned"

    new_amount = BigDecimal.new("8.8")
    sponsor.donate_to(project, new_amount)
    donation.reload

    assert donation.stripe_subscription_id != tmp_stripe_subscription_id, "Stripe Subscription ID has not changed"
    assert donation.amount == new_amount, "Donation amount has not been updated: #{donation.amount} != #{new_amount}"

    sponsor.cancel_donation_for(project)
  end
end
