class StripeEvent < ActiveRecord::Base
  include Stripe::Callbacks

  after_stripe_event do |target, event|
    StripeEvent.record_event(target, event)
  end

  def self.record_event(target, event)
    target_hash = target.as_json
    event_hash = event.as_json
    StripeEvent.create(
      event_id: event_hash.fetch("id", nil),
      event_type: event_hash.fetch("type", nil),
      object_type: target_hash.fetch("object", nil), 
      object_id: target_hash.fetch("id", nil), 
      object_description: target_hash.fetch("description", nil), 
      json: event.to_json
    )
  end
end
