require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SiteMecenus
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << Rails.root.join('lib')

    config.stripe.secret_key = Rails.application.secrets.stripe_secret_key
    config.stripe.publishable_key = Rails.application.secrets.stripe_publishable_key
    config.trial_end = ENV["TRIAL_END"]
  end
end
