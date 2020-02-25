# frozen_string_literal: true

require 'pry' if Gem.loaded_specs.key?('pry')

require 'forwardable'
require 'ostruct'
require 'pathname'
require 'singleton'

require 'action_controller'
require 'action_dispatch'
require 'action_view'
require 'active_support/all'
require 'jsonapi/deserializable'
require 'jsonapi/serializable'
require 'rack/utils'
require 'yaml'
require 'zeitwerk'

# Without this, Zeitwerk hiccups in certain cases...
module SharkOnLambda; end

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.ignore(File.expand_path('shark-on-lambda.rb', __dir__))
  loader.inflector.inflect(
    'rspec' => 'RSpec',
    'version' => 'VERSION'
  )
  loader.setup
  loader.eager_load
end

# Top-level module for this gem.
module SharkOnLambda
  class << self
    extend Forwardable

    attr_writer :logger

    def_instance_delegators :config, :root, :stage

    def application
      @application ||= Application.new
    end

    def config
      Configuration.instance
    end

    def configure
      yield(config, secrets)
    end

    def initialize!
      yield(config, secrets)

      Configuration.load(stage)
      Secrets.load(stage)
      run_initializers

      true
    end

    def load_configuration
      Configuration.load(stage)
      Secrets.load(stage)

      true
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def reset_configuration
      known_stage = config.stage
      known_root = config.root

      Configuration.reset
      Secrets.reset

      config.root = known_root
      config.stage = known_stage

      true
    end

    def secrets
      Secrets.instance
    end

    protected

    def run_initializers
      initializers_path = root.join('config', 'initializers')
      Dir.glob(initializers_path.join('*.rb')).each do |path|
        load path
      end
    end
  end
end
