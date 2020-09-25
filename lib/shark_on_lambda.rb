# frozen_string_literal: true

require 'pry' if Gem.loaded_specs.key?('pry')

require 'erb'
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
require 'rack-on-lambda'
require 'yaml'
require 'zeitwerk'

# Without this, Zeitwerk hiccups in certain cases...
module SharkOnLambda; end

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.ignore(File.expand_path('shark-on-lambda.rb', __dir__))
  loader.ignore(File.expand_path('shark_on_lambda/rake_tasks.rb', __dir__))
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

    attr_writer :application, :cache, :env, :global_cache, :logger

    def_instance_delegators :application, :initialize!, :root

    def application
      @application ||= Application.new
    end

    def configuration
      application.config
    end

    def cache
      @cache ||= ActiveSupport::Cache::NullStore.new
    end

    def env
      @env || ENV['STAGE'].presence || 'development'
    end

    def global_cache
      @global_cache ||= ActiveSupport::Cache::NullStore.new
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
