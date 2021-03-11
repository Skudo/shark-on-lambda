# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module RequestHelpers
      attr_writer :app

      SUPPORTED_HTTP_METHODS = %w[
        DELETE GET HEAD OPTIONS PATCH POST PUT
      ].freeze

      SUPPORTED_HTTP_METHODS.each do |http_method|
        define_method(http_method.underscore) do |action, **options|
          make_request(http_method, action, **options)
        end
      end

      def app
        @app ||= SharkOnLambda.application
      end

      def response
        raise 'You must make a request before you can request a response.' if @response.nil?

        @response
      end

      private

      def build_env(method, action, **options)
        headers = options.fetch(:headers, {})
        env_builder = EnvBuilder.new(
          method: method,
          controller: described_class,
          action: action,
          headers: normalized_headers(headers),
          params: options.fetch(:params, {})
        )
        env_builder.build
      end

      def default_content_type
        'application/vnd.api+json'
      end

      def make_request(method, action, **options)
        env = build_env(method, action, **options)

        status, headers, body = app.call(env)
        errors = env['rack.errors']
        @response = Rack::MockResponse.new(status, headers, body, errors)
      end

      def normalized_headers(headers)
        headers.transform_keys! { |key| key.to_s.downcase }
        headers['content-type'] ||= default_content_type
        headers
      end
    end
  end
end
