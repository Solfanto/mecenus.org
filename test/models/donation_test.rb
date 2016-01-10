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

    sponsor.donate_to(project, "75")
    donation = sponsor.donations.find_by(project_id: project.id)

    tmp_stripe_plan_id = donation.stripe_plan_id
    tmp_stripe_subscription_id = donation.stripe_subscription_id

    assert !donation.stripe_plan_id.nil?, "Stripe Plan ID is not assigned"
    assert !donation.stripe_subscription_id.nil?, "Stripe Subscription ID is not assigned"

    sponsor.donate_to(project, "88")
    donation.reload

    assert donation.stripe_subscription_id != tmp_stripe_subscription_id, "Stripe Subscription ID has not changed"
    assert donation.amount == 88, "Donation amount has not been updated"

    sponsor.cancel_donation_for(project)
  end
end
