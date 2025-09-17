require "simplecov"
SimpleCov.start :rails do
  enable_coverage :branch
  command_name "Minitest"

  formatter SimpleCov::Formatter::HTMLFormatter
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "minitest/reporters"
require_relative "support/lizard_reporter"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new,
  LizardReporter.new
]

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
  end
end
