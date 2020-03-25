# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module Helpers
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
        build_options = {
          method: method,
          headers: options[:headers],
          params: options[:params],
          path_parameters: options[:path_parameters]
        }

        if controller?
          build_options.merge!(
            controller: controller_name,
            action: action)
        end
        if path_info?(action)
          build_options.merge!(path_info: action)
        end

        EnvBuilder.new(build_options).build
      end

      def controller?
        controller_name.present?
      end

      def controller_name
        self.class.ancestors.find do |klass|
          klass.name.end_with?('Controller')
        end&.description
      end

      def default_content_type
        'application/json'
      end

      def dispatch_request(env, skip_middleware: false)
        return SharkOnLambda.application.call(env) unless skip_middleware

        controller_class = env['shark.controller'].constantize
        action = env['shark.action']

        request = Request.new(env)
        response = Response.new
        controller_class.dispatch(action, request, response)
        response.prepare!
      end

      def headers_with_content_type(headers)
        headers ||= {}
        headers.transform_keys! { |key| key.to_s.downcase }
        headers['content-type'] ||= default_content_type
        headers
      end

      def make_request(method, action, options = {})
        if  !path_info?(action) && !controller?
          raise ArgumentError, 'Cannot find controller name.'
        end

        options = options.with_indifferent_access
        options[:headers] = headers_with_content_type(options[:headers])

        env = build_env(method, action, options)

        status, headers, body = dispatch_request(
          env,
          skip_middleware: options[:skip_middleware]
        )
        errors = env['rack.errors']
        @response = Rack::MockResponse.new(status, headers, body, errors)
      end

      def path_info?(action)
        action.is_a?(String) && URI.parse(action).path.present?
      rescue
        false
      end
    end
  end
end
