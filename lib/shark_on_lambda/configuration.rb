# frozen_string_literal: true

module SharkOnLambda
  class Configuration < OpenStruct
    attr_reader :root

    def middleware
      @middleware ||= ActionDispatch::MiddlewareStack.new do |middleware_stack|
        middleware_stack.use Middleware::LambdaLogger
      end
    end

    def root=(new_root)
      @root = Pathname.new(new_root)
    end
  end
end
