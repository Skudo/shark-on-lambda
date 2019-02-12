# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class BaseController
      include FilterActions
      include HttpResponseValidation

      attr_reader :event, :context

      def initialize(event:, context:)
        @event = event
        @context = context
      end

      def call(method)
        call_with_filter_actions(method)
        response.to_h
      end

      def params
        @params ||= Parameters.new(request)
      end

      def redirect_to(url, status: 307, message: nil)
        status = status.to_i
        validate_redirection_url!(url)
        validate_redirection_status!(status)

        uri = URI.parse(url)
        response.set_header('Location', uri.to_s)
        body = message.presence || "You are being redirected to: #{url}"

        render(body, status: status)
      end

      def render(object, status: 200)
        update_response(status: status, body: object)
        respond!
      end

      def request
        @request ||= Request.new(event: event, context: context)
      end

      def response
        @response ||= Response.new
      end

      protected

      def respond!
        if responded?
          raise Errors[500],
                '#render or #redirect_to was called more than once.'
        end

        @responded = true
        response
      end

      def responded?
        @responded.present?
      end

      def update_response(status:, body: nil)
        status = status.to_i
        validate_response_status!(status)

        response.status = status
        response.body = body.to_s.presence
      end
    end
  end
end
