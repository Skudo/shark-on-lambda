# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module Helpers
      def delete(controller_method, options = {})
        make_request('DELETE', controller_method, options)
      end

      def get(controller_method, options = {})
        make_request('GET', controller_method, options)
      end

      def patch(controller_method, options = {})
        make_request('PATCH', controller_method, options)
      end

      def post(controller_method, options = {})
        make_request('POST', controller_method, options)
      end

      def put(controller_method, options = {})
        make_request('PUT', controller_method, options)
      end

      def response
        if @response.nil?
          raise 'You must make a request before you can request a response.'
        end

        @response
      end

      private

      def build_env(method, action, options = {})
        env_builder = EnvBuilder.new(
          method: method,
          controller: controller_name,
          action: action,
          headers: options[:headers],
          params: options[:params]
        )
        env_builder.build
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
        raise ArgumentError, 'Cannot find controller name.' unless controller?

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
    end
  end
end
