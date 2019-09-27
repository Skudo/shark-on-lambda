# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class BaseHandler
      class << self
        attr_writer :controller_class

        def controller_class
          return @controller_class if defined?(@controller_class)

          name_inferrer = Inferrers::NameInferrer.from_handler_name(name)
          controller_class_name = name_inferrer.controller
          @controller_class = controller_class_name.safe_constantize
        end

        protected

        def known_actions
          controller_class.public_instance_methods(false)
        end

        def method_missing(name, *args, &block)
          return super unless respond_to_missing?(name)

          instance = new
          instance.call(name, *args, &block)
        end

        def respond_to_missing?(name, _include_all = false)
          known_actions.include?(name)
        end
      end

      def call(action, event:, context:)
        controller_class = self.class.controller_class
        controller = controller_class.new(event: event, context: context)
        controller.call(action)
      rescue StandardError => e
        handle_error(e)
      end

      protected

      def client_error?(error)
        error.is_a?(Errors::Base) && (400..499).cover?(error.status)
      end

      def error_body(status, message)
        {
          errors: [{
            status: status.to_s,
            title: ::Rack::Utils::HTTP_STATUS_CODES[status],
            detail: message
          }]
        }.to_json
      end

      def error_response(error)
        status = error.try(:status) || 500

        {
          statusCode: status,
          headers: {
            'Content-Type' => 'application/vnd.api+json'
          },
          body: error_body(status, error.message)
        }
      end

      def handle_error(error)
        unless client_error?(error)
          SharkOnLambda.logger.error(error.message)
          SharkOnLambda.logger.error(error.backtrace.join("\n"))
          ::Honeybadger.notify(error) if defined?(::Honeybadger)
        end

        error_response(error)
      end
    end
  end
end
