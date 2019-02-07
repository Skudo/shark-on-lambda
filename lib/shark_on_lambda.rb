# frozen_string_literal: true

require 'ostruct'
require 'singleton'

require 'doorkeeper/core'
require 'jsonapi/deserializable'
require 'jsonapi/serializable'
require 'rack/utils'

require 'shark_on_lambda/version'

require 'shark_on_lambda/concerns/filter_actions'
require 'shark_on_lambda/concerns/resettable_singleton'
require 'shark_on_lambda/concerns/yaml_config_loader'

require 'shark_on_lambda/configuration'
require 'shark_on_lambda/secrets'

require 'shark_on_lambda/inferrers/name_inferrer'
require 'shark_on_lambda/inferrers/serializer_inferrer'

require 'shark_on_lambda/api_gateway/serializers/base_error_serializer'
require 'shark_on_lambda/api_gateway/concerns/doorkeeper_authentication'
require 'shark_on_lambda/api_gateway/concerns/jsonapi_support'
require 'shark_on_lambda/api_gateway/base_controller'
require 'shark_on_lambda/api_gateway/base_handler'
require 'shark_on_lambda/api_gateway/errors'
require 'shark_on_lambda/api_gateway/headers'
require 'shark_on_lambda/api_gateway/jsonapi_params'
require 'shark_on_lambda/api_gateway/jsonapi_renderer'
require 'shark_on_lambda/api_gateway/parameters'
require 'shark_on_lambda/api_gateway/request'
require 'shark_on_lambda/api_gateway/response'

# Top-level module for this gem.
module SharkOnLambda
  class << self
    extend Forwardable

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
      initializers_path = File.join(root, 'config', 'initializers')
      Dir.glob(File.join(initializers_path, '*.rb')).each do |path|
        load path
      end
    end
  end
end
