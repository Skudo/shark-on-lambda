# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class BaseController
      include FilterActions
      include JsonapiSupport

      attr_reader :event, :context
      attr_reader :params, :request, :response

      def initialize(event:, context:)
        @event = event
        @context = context

        @request = Request.new(event: event, context: context)
        @response = Response.new
        @params = Parameters.new(request)
      end

      def call(method)
        call_with_filter_actions(method)
        response.to_h
      end

      protected

      def redirect_to(url, status: 307, headers: {})
        unless url?(url)
          raise Errors[500], "`#{url}' is not a valid redirection target."
        end

        response.status = status
        headers.each_pair { |key, value| response.set_header(key, value) }
        response.set_header('Location', url)
        response.body = nil

        respond!
      end

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

      def url?(url)
        URI.parse(url.to_s)
        url.present?
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
