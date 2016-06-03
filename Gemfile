source 'https://rubygems.org'

ruby "2.3.1"

gem 'devise'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'rails-timeago', '~> 2.0'
gem 'carrierwave'
gem 'mini_magick'
gem 'redcarpet'
gem 'rails_autolink'
gem 'country_select'

gem 'stripe-rails'
gem 'paypal-sdk-rest'

gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'capistrano-sidekiq', group: :development
gem 'whenever'

gem 'roboto'

gem 'bullet', group: :development
gem 'memoist'
gem 'dalli'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.4'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass'
gem 'bootstrap-social-rails', git: 'https://github.com/denys281/bootstrap-social-rails'
gem 'jquery-turbolinks'
gem 'font-awesome-sass', '~> 4.5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'
gem 'puma'
gem 'rails_12factor', group: :production

# Use Capistrano for deployment
gem 'capistrano-3-rails-template', git: 'https://github.com/n-studio/capistrano-3-rails-template.git', branch: 'passenger', group: :development
gem 'capistrano-db-tasks', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'guard'
  gem 'guard-minitest'
end

group :test do
  gem 'minitest-reporters'
  gem 'test_after_commit' # deprecated for Rails 5+: https://github.com/rails/rails/pull/18458
end

source 'https://rails-assets.org' do
end

