# frozen_string_literal: true

module SharkOnLambda
  class ApiGatewayHandler
    class << self
      attr_writer :controller_class_name

      def controller_action?(action)
        controller_actions.include?(action.to_sym)
      end

      def controller_class_name
        return @controller_class_name if defined?(@controller_class_name)

        name_inferrer = Inferrers::NameInferrer.from_handler_name(name)
        @controller_class_name = name_inferrer.controller
      end

      private

      def controller_actions
        return [] if controller_class.nil?

        controller_class.public_instance_methods(false)
      end

      def controller_class
        controller_class_name.safe_constantize
      end

      def method_missing(action, *args, &_block)
        return super unless respond_to_missing?(action)

        new.call(action, *args)
      end

      def respond_to_missing?(name, _include_all = false)
        controller_action?(name)
      end
    end

    attr_reader :application, :env
    delegate :context, :event, to: :adapter

    def initialize
      @application = Application.new
    end

    def call(action, event:, context:)
      raise NoMethodError unless self.class.controller_action?(action)

      adapter = RackAdapters::ApiGateway.new(context: context, event: event)
      env = adapter.env
      env['shark.controller'] = self.class.controller_class_name
      env['shark.action'] = action.to_s

      status, headers, body = @application.call(env)
      adapter.build_response(status, headers, body)
    end
  end
end
