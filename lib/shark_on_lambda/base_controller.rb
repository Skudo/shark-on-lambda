# frozen_string_literal: true

module SharkOnLambda
  class BaseController
    include ::ActiveSupport::Rescuable
    include SharkOnLambda::Concerns::FilterActions
    include Concerns::HttpResponseValidation

    attr_reader :action_name, :event, :context

    class << self
      def rescue_with_default_handler(error)
        Response.new.tap do |response|
          response.status = error.try(:status) || 500
          response.body = {
            message: error.message
          }.to_json
        end
      end

      private

      def known_actions(include_all = false)
        actions = public_instance_methods(include_all)
        actions.delete(:call)
        actions
      end

      def client_error?(error)
        error.is_a?(Errors::Base) && (400..499).cover?(error.status)
      end

      def log_error(error)
        return if client_error?(error)

        SharkOnLambda.logger.error(error.message)
        SharkOnLambda.logger.error(error.backtrace.join("\n"))
        ::Honeybadger.notify(error) if defined?(::Honeybadger)
      end

      def method_missing(name, *args, &block)
        instance = new(*args)
        respond_to_missing?(name) ? instance.call(name) : super
      rescue StandardError => e
        log_error(e)
        error_response = rescue_with_default_handler(e)
        error_response.to_h
      end

      def respond_to_missing?(name, include_all = false)
        known_actions(include_all).include?(name)
      end
    end

    def initialize(event:, context:)
      @event = event
      @context = context
    end

    def call(method)
      @action_name = method.to_s

      begin
        call_with_filter_actions(method)
      rescue StandardError => e
        unless rescue_with_handler(e)
          @response = self.class.rescue_with_default_handler(e)
        end
      end

      response.to_h
    end

    def params
      @params ||= Parameters.new(request)
    end

    def redirect_to(url, status: 307, message: nil)
      status = status.to_i
      validate_url!(url)
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

    private

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
