class StripeEvent < ActiveRecord::Base
  include Stripe::Callbacks

  after_stripe_event do |target, event|
    StripeEvent.create(json: event.to_s)
  end
end
