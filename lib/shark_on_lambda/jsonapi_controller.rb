# frozen_string_literal: true

module SharkOnLambda
  class JsonapiController < BaseController
    class << self
      def rescue_with_default_handler(error)
        super.tap do |response|
          response.headers['content-type'] = 'application/vnd.api+json'
          response.body = error_body(response.response_code, error.message)
        end
      end

      private

      def error_body(status, message)
        {
          errors: [{
            status: status.to_s,
            title: ::Rack::Utils::HTTP_STATUS_CODES[status],
            detail: message
          }]
        }.to_json
      end
    end

    def redirect_to(url, options = {})
      status = options[:status] || 307
      validate_url!(url)
      validate_redirection_status!(status)

      uri = URI.parse(url)
      response.set_header('Location', uri.to_s)
      render(nil, status: status)
    end

    def render(object, options = {})
      status = options.delete(:status) || 200
      renderer_options = jsonapi_params.to_h.merge(options)

      body = serialize(object, renderer_options)
      update_response(status: status, body: body)

      respond!
    end

    private

    def jsonapi_params
      @jsonapi_params ||= JsonapiParameters.new(params)
    end

    def jsonapi_renderer
      @jsonapi_renderer ||= JsonapiRenderer.new
    end

    def serialize(object, options = {})
      jsonapi_renderer.render(object, options)
    end
  end
end
