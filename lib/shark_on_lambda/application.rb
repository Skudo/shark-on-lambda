# frozen_string_literal: true

module SharkOnLambda
  class Application
    attr_reader :middleware, :routes

    def initialize
      router_config = ActionDispatch::Routing::RouteSet::Config.new(nil, true)
      @routes = ActionDispatch::Routing::RouteSet.new_with_config(router_config)
      @middleware = ActionDispatch::MiddlewareStack.new do |middleware_stack|
        middleware_stack.use Middleware::LambdaLogger
      end
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      middleware_stack = middleware.build(routes)
      middleware_stack.call(env)
    end
  end
end
