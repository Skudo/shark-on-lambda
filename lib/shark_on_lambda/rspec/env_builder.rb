# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    class EnvBuilder
      attr_reader :action, :controller, :headers, :method, :params

      def initialize(options = {})
        @method = options.fetch(:method).to_s.upcase
        @controller = options.fetch(:controller)
        @action = options.fetch(:action)

        @headers = (options[:headers] || {}).deep_stringify_keys
        @headers.transform_keys!(&:downcase)
        @params = options[:params] || {}

        initialize_env
        add_headers
        add_request_body
      end

      def build
        env.deep_stringify_keys
      end

      private

      attr_reader :env

      def add_header(name, value)
        name = name.upcase.tr('-', '_')
        key = case name
              when 'CONTENT_LENGTH', 'CONTENT_TYPE' then name
              else "HTTP_#{name}"
              end
        @env[key] = value.to_s
      end

      def add_headers
        headers.each_pair { |name, value| add_header(name, value) }
      end

      def add_request_body
        return if %w[GET HEAD OPTIONS].include?(env['REQUEST_METHOD'])
        return unless params.is_a?(Hash)

        body = params.to_json

        env['rack.input'] = StringIO.new(body).set_encoding(Encoding::BINARY)
        set_content_type_and_content_length
      end

      def initialize_env
        @env = Rack::MockRequest.env_for(
          request_uri.to_s,
          method: method,
          params: params
        )
      end

      def request_path
        return action if action.is_a?(String)

        path_params = params.symbolize_keys.merge(
          controller: controller.sub(/Controller$/, '').underscore,
          action: action,
          only_path: true
        )
        path = SharkOnLambda.application.routes.url_for(path_params, nil)
        URI.parse(path).path
      end

      def request_uri
        URI.join('https://localhost:9292', request_path).tap do |uri|
          uri.query = nil
        end
      end

      def set_content_type_and_content_length
        env['CONTENT_TYPE'] = headers['content-type']
        env['CONTENT_LENGTH'] = env['rack.input'].length.to_s
      end
    end
  end
end
