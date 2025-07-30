require "simplecov"
require "undercover/simplecov_formatter"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Undercover
]

SimpleCov.start "rails" do
  add_filter(/^\/test\//)
  enable_coverage :branch
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
  def craftable_item_name
    "Action: Auto-Craft [IV]"
  end

  def ingredient_item_name
    "Ashen Jewel"
  end
end
