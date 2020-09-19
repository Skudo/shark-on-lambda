# frozen_string_literal: true

module SharkOnLambda
  class Application
    attr_reader :routes

    delegate :middleware, :root, to: :config

    class << self
      def config
        Configuration.instance
      end

      def inherited(subclass)
        super

        SharkOnLambda.application = subclass.new
      end
    end

    def initialize
      register_jsonapi_rendering
      initialize_router
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      middleware_stack = middleware.build(routes)
      middleware_stack.call(env)
    end

    def config
      self.class.config
    end

    def config_for(name, env: SharkOnLambda.env)
      config = load_config_file(name, env: env)
      config.deep_merge(load_config_file("#{name}.local", env: env))
    end

    def initialize!
      load_routes
      run_initializers
    end

    private

    def initialize_router
      router_config = ActionDispatch::Routing::RouteSet::Config.new(nil, true)
      @routes = ActionDispatch::Routing::RouteSet.new_with_config(router_config)
    end

    def load_config_file(name, env:)
      filename = "#{name}.yml"
      config_file = SharkOnLambda.root.join('config', filename)
      unless config_file.exist?
        raise ArgumentError,
              "Could not load configuration. No such file - #{config_file}"
      end

      erb_parsed_config = ERB.new(config_file.read).result
      config = YAML.safe_load(erb_parsed_config, [], [], true, filename) || {}
      config.fetch(env, {}).with_indifferent_access
    end

    def load_routes
      routes_path = SharkOnLambda.root.join('config', 'routes.rb').to_s
      load routes_path if File.exist?(routes_path)
    end

    def register_jsonapi_rendering
      ::Mime::Type.register('application/vnd.api+json', :jsonapi)
      ::ActionDispatch::Request.parameter_parsers[:jsonapi] =
        ::ActionDispatch::Request.parameter_parsers[:json].dup
    end

    def run_initializers
      initializers_folder = SharkOnLambda.root.join('config', 'initializers')
      Dir.glob(initializers_folder.join('*.rb')).each { |path| load path }
    end
  end
end
