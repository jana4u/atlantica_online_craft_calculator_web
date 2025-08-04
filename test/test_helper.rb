require "simplecov"
require "undercover/simplecov_formatter"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Undercover
]

SimpleCov.start "rails" do
  add_filter(/^\/test\//)
  enable_coverage :branch
  enable_coverage_for_eval
  add_group "Views", "app/views"
end

# Disabling warnings about coverage data exceeding number of lines in *.erb files.
# Solution based on: https://github.com/simplecov-ruby/simplecov/issues/1057
module SimpleCov
  class SourceFile
    private

    alias_method :coverage_exceeding_source_warn_original, :coverage_exceeding_source_warn

    def coverage_exceeding_source_warn
      unless filename.end_with?(".erb")
        coverage_exceeding_source_warn_original
      end
    end
  end
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
