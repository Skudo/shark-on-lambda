# frozen_string_literal: true

module SharkOnLambda
  class BaseController
    include ::ActiveSupport::Rescuable
    include SharkOnLambda::Concerns::FilterActions
    include Concerns::HttpResponseValidation

    attr_reader :action_name, :event, :context

    def initialize(event:, context:)
      @event = event
      @context = context
    end

    def call(method)
      @action_name = method.to_s

      begin
        call_with_filter_actions(method)
      rescue StandardError => e
        rescue_with_handler(e) || raise(e)
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
