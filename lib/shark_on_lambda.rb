# frozen_string_literal: true

require 'pry' if Gem.loaded_specs.key?('pry')

require 'forwardable'
require 'ostruct'
require 'pathname'
require 'singleton'

require 'active_support/all'
require 'jsonapi/deserializable'
require 'jsonapi/serializable'
require 'rack/utils'
require 'yaml'

require 'shark_on_lambda/version'

require 'shark_on_lambda/concerns/filter_actions'
require 'shark_on_lambda/concerns/http_response_validation'
require 'shark_on_lambda/concerns/resettable_singleton'
require 'shark_on_lambda/concerns/yaml_config_loader'

require 'shark_on_lambda/configuration'
require 'shark_on_lambda/secrets'

require 'shark_on_lambda/inferrers/name_inferrer'
require 'shark_on_lambda/inferrers/serializer_inferrer'

require 'shark_on_lambda/serializers/base_error_serializer'

require 'shark_on_lambda/base_controller'
require 'shark_on_lambda/errors'
require 'shark_on_lambda/headers'
require 'shark_on_lambda/jsonapi_controller'
require 'shark_on_lambda/jsonapi_parameters'
require 'shark_on_lambda/jsonapi_renderer'
require 'shark_on_lambda/parameters'
require 'shark_on_lambda/query'
require 'shark_on_lambda/request'
require 'shark_on_lambda/response'

# Top-level module for this gem.
module SharkOnLambda
  class << self
    extend ::Forwardable

    attr_writer :logger

    def_instance_delegators :config, :root, :stage

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
      @logger ||= ::Logger.new(STDOUT)
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
