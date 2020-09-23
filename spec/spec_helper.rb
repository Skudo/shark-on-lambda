# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'active_model'
require 'factory_bot'

ENV['STAGE'] ||= 'test'

require_relative 'test_application/application'

Dir['shared_contexts/**/*.rb', base: __dir__].each do |shared_context|
  load shared_context
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    SharkOnLambda.logger.level = :warn
  end

  config.before do
    Class.new(SharkOnLambda::Application) do
      self.config.root = File.expand_path('test_application', __dir__)
    end
    SharkOnLambda.application.initialize!
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
