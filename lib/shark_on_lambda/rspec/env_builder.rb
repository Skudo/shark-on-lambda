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
        @params = options[:params]

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
        env['CONTENT_TYPE'] = 'application/json'
        env['CONTENT_LENGTH'] = body.bytesize.to_s
      end

      def initialize_env
        @env = ::Rack::MockRequest.env_for(
          'https://localhost:9292',
          method: method,
          params: params,
          'shark.controller' => controller,
          'shark.action' => action
        )
      end
    end
  end
end
