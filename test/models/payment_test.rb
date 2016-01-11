require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "payment is correctly processed" do
    project = projects(:mecenus_org)
    assert project.donations_count == 0, "project.donations_count != 0 (#{project.donations_count})"

    amount = 7.0
    sponsor = users(:sponsor)
    add_testing_payment_to_user(sponsor)
    sponsor.donate_to(project, amount)
    donation = sponsor.donations.find_by(project_id: project.id)

    other_amount = 9.0
    other_sponsor = users(:other_sponsor)
    add_testing_payment_to_user(other_sponsor)
    result = other_sponsor.donate_to(project, other_amount)
    assert result, "Donation failed: #{other_sponsor.errors.full_messages.to_sentence}"
    other_donation = other_sponsor.donations.find_by(project_id: project.id)

    Payment.process_payment({
      "customer" => sponsor.stripe_customer_id,
      "amount" => 7,
      "currency" => "usd",
      "metadata" => {
        "donation_id" => donation.id
      }
    },
    {
      "created" => Time.now.to_i.to_s
    },
    :succeeded)

    Payment.process_payment({
      "customer" => other_sponsor.stripe_customer_id,
      "amount" => 9,
      "currency" => "usd",
      "metadata" => {
        "donation_id" => other_donation.id
      }
    },
    {
      "created" => Time.now.to_i.to_s
    },
    :succeeded)

    record = project.donation_records.order("created_at ASC").last
    assert record.amount == amount + other_amount, "Donation record has incorrect amount: #{record.amount} instead of #{amount + other_amount}"
    assert !record.aggregated_at.nil?, "Record is not aggregated: #{record.aggregated_at}"

    sponsor.cancel_donation_for(project)
    other_sponsor.cancel_donation_for(project)
  end

  test "payment is correctly processed even if one payment fails" do
    project = projects(:mecenus_org)

    amount = 7.0
    sponsor = users(:sponsor)
    add_testing_payment_to_user(sponsor)
    result = sponsor.donate_to(project, amount)
    assert result, "Donation failed: #{sponsor.errors.full_messages.to_sentence}"
    donation = sponsor.donations.find_by(project_id: project.id)

    other_amount = 9.0
    other_sponsor = users(:other_sponsor)
    add_testing_payment_to_user(other_sponsor)
    other_sponsor.donate_to(project, other_amount)
    other_donation = other_sponsor.donations.find_by(project_id: project.id)

    failed_amount = 18.0
    failed_sponsor = users(:other_sponsor)
    add_testing_payment_to_user(failed_sponsor)
    failed_sponsor.donate_to(project, failed_amount)
    failed_donation = failed_sponsor.donations.find_by(project_id: project.id)

    Payment.process_payment({
      "customer" => sponsor.stripe_customer_id,
      "amount" => amount,
      "currency" => "usd",
      "metadata" => {
        "donation_id" => donation.id
      }
    },
    {
      "created" => Time.now.to_i.to_s
    },
    :succeeded)

    Payment.process_payment({
      "customer" => other_sponsor.stripe_customer_id,
      "amount" => other_amount,
      "currency" => "usd",
      "metadata" => {
        "donation_id" => other_donation.id
      }
    },
    {
      "created" => Time.now.to_i.to_s
    },
    :succeeded)

    Payment.process_payment({
      "customer" => failed_sponsor.stripe_customer_id,
      "amount" => failed_amount,
      "currency" => "usd",
      "metadata" => {
        "donation_id" => failed_donation.id
      }
    },
    {
      "created" => Time.now.to_i.to_s
    },
    :failed)

    record = project.donation_records.order("created_at ASC").last
    assert record.amount == amount + other_amount, "Donation record has incorrect amount: #{record.amount} instead of #{amount + other_amount}"
    assert !record.aggregated_at.nil?, "Record is not aggregated: #{record.aggregated_at}"

    sponsor.cancel_donation_for(project)
    other_sponsor.cancel_donation_for(project)
    failed_sponsor.cancel_donation_for(project)
  end
end
