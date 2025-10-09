source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Use Sass to process CSS
gem "sassc-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Use WEBrick as the app server
  gem "webrick"
end

# Bootstrap 5 ruby gem for Ruby on Rails.
gem "bootstrap", "~> 5.3.5"

# Delivering exception notifications by email
gem "exception_notification"

group :development do
  gem "standard", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-minitest", require: false
  gem "erb_lint", require: false
end

group :test do
  gem "simplecov", require: false
  gem "undercover", require: false
end

# Atlantica Online Craft Calculator
gem "atlantica_online_craft_calculator", github: "jana4u/atlantica_online_craft_calculator"
