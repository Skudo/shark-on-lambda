# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module RequestHelpers
      def delete(action, options = {})
        make_request('DELETE', action, options)
      end

      def get(action, options = {})
        make_request('GET', action, options)
      end

      def patch(action, options = {})
        make_request('PATCH', action, options)
      end

      def post(action, options = {})
        make_request('POST', action, options)
      end

      def put(action, options = {})
        make_request('PUT', action, options)
      end

      def response
        if @response.nil?
          raise 'You must make a request before you can request a response.'
        end

        @response
      end

      private

      def build_env(method, action, options = {})
        path_parameters = options.delete(:path_parameters) || {}
        options[:params] = (options[:params] || {}).merge(path_parameters)

        env_builder = EnvBuilder.new(
          method: method,
          controller: controller_name,
          action: action,
          headers: options[:headers],
          params: options[:params]
        )
        env_builder.build
      end

      def controller_name
        described_class.name
      end

      def default_content_type
        'application/vnd.api+json'
      end

      def headers_with_content_type(headers)
        headers ||= {}
        headers.transform_keys! { |key| key.to_s.downcase }
        headers['content-type'] ||= default_content_type
        headers
      end

      def make_request(method, action, options = {})
        options = options.with_indifferent_access
        options[:headers] = headers_with_content_type(options[:headers])

        env = build_env(method, action, options)

        status, headers, body = SharkOnLambda.application.call(env)
        errors = env['rack.errors']
        @response = Rack::MockResponse.new(status, headers, body, errors)
      end
    end
  end
end
