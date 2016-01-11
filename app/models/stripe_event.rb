class StripeEvent < ActiveRecord::Base
  include Stripe::Callbacks

  after_stripe_event do |target, event|
    event_hash = event.as_json
      event_id: event_hash.fetch("id", nil),
      event_type: event_hash.fetch("type", nil),
      object_type: event_hash.fetch("data", {}).fetch("object", {}).fetch("object", nil), 
      object_id: event_hash.fetch("data", {}).fetch("object", {}).fetch("id", nil), 
      object_description: event_hash.fetch("data", {}).fetch("object", {}).fetch("description", nil), 
      json: event.to_json
    )
  end
end
