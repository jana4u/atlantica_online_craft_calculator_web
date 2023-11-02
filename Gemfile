source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Use Sass to process CSS
gem "sassc-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

# Use Unicorn as the app server
gem "unicorn-rails"

# Twitter Bootstrap 2.x
gem "bootstrap-sass", "< 3"
# Required for using of bootstrap-sass 2.x in Rails.
gem "sass-rails", ">= 6"

# Use jquery as the JavaScript library
gem "jquery-rails"

# Delivering exception notifications by email
gem "exception_notification"

group :development do
  gem "standard", require: false
end

# Atlantica Online Craft Calculator
gem "atlantica_online_craft_calculator_engine", github: "jana4u/atlantica_online_craft_calculator_engine"
gem "atlantica_online_craft_calculator", github: "jana4u/atlantica_online_craft_calculator"
