require_relative '../yryr_icon'

require 'database_rewinder'
require 'rack/test'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

module SinatraTestHelper
  include Rack::Test::Methods
  def app; YRYRIcon end
end

RSpec.configure do |config|
  include SinatraTestHelper

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end
end
