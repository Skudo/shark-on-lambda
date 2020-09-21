# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    class EnvBuilder
      def initialize(**options)
        @options = options
      end

      def build
        initialize_env
        add_headers
        add_request_body_as_json if body? && jsonable_params? && json_request?
        env.deep_stringify_keys
      end

      private

      attr_reader :env

      def action
        @options.fetch(:action)
      end

      def add_headers
        headers.each_pair do |name, value|
          name = name.upcase.tr('-', '_')
          key = case name
                when 'CONTENT_LENGTH', 'CONTENT_TYPE' then name
                else "HTTP_#{name}"
                end
          env[key] = value.to_s
        end
      end

      def add_request_body_as_json
        body = params.to_json

        env['rack.input'] = StringIO.new(body).set_encoding(Encoding::BINARY)
        env['CONTENT_TYPE'] = headers['content-type']
        env['CONTENT_LENGTH'] = env['rack.input'].length.to_s
      end

      def as
        @options.fetch(:as, :json)
      end

      def body?
        !%w[GET HEAD OPTIONS].include?(env['REQUEST_METHOD'])
      end

      def initialize_env
        @env = Rack::MockRequest.env_for(
          request_uri.to_s,
          method: method,
          params: params
        )
      end

      def controller
        @options.fetch(:controller, nil)
      end

      def headers
        return @headers if defined?(@headers)

        @headers = @options.fetch(:headers, {}).deep_stringify_keys
        @headers.transform_keys!(&:downcase)
        @headers
      end

      def json_request?
        as == :json
      end

      def jsonable_params?
        params.is_a?(Hash)
      end

      def method
        @options.fetch(:method).to_s.upcase
      end

      def params
        @options.fetch(:params, {}).deep_stringify_keys
      end

      def path_from_routes
        path_params = {
          controller: controller.name.underscore.sub(/_controller$/, ''),
          action: action,
          only_path: true
        }
        url = SharkOnLambda.application.routes.url_for(path_params, nil)
        URI.parse(url).path
      end

      def request_uri
        return @request_uri if defined?(@request_uri)

        path = action.is_a?(String) ? action : path_from_routes
        @request_uri = URI.join('https://localhost:9292', path)
      end
    end
  end
end
