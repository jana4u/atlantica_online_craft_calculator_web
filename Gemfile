source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.0.8"

# Use SCSS for stylesheets
gem "sass-rails", ">= 6"

# Use Unicorn as the app server
gem "unicorn-rails"

# Twitter Bootstrap 2.x
gem "bootstrap-sass", "< 3"

# Use jquery as the JavaScript library
gem "jquery-rails"

# Delivering exception notifications by email
gem "exception_notification"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem "standard", require: false
end

# Atlantica Online Craft Calculator
gem "atlantica_online_craft_calculator_engine", github: "jana4u/atlantica_online_craft_calculator_engine"
gem "atlantica_online_craft_calculator", github: "jana4u/atlantica_online_craft_calculator"
