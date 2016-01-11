class StripeEvent < ActiveRecord::Base
  include Stripe::Callbacks

  after_stripe_event do |target, event|
    StripeEvent.create(
      event_id: event.fetch("id"),
      event_type: event.fetch("type"),
      object_type: event.fetch("data", {}).fetch("object", {}).fetch("object"), 
      object_id: event.fetch("data", {}).fetch("object", {}).fetch("id"), 
      object_description: event.fetch("data", {}).fetch("object", {}).fetch("description"), 
      json: event.to_s
    )
  end
end
