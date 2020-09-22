# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Honeybadger < Base
      attr_reader :tags

      def initialize(app, tags: '')
        super(app)

        @tags = tags
      end

      def call!(env)
        app.call(env)
      rescue StandardError => e
        notify(e, env) unless shark_error?(e) && client_error?(e)

        raise e
      end

      private

      def client_error?(error)
        error.respond_to?(:status) && error.status < 500
      end

      def notify(error, env)
        params = env['action_dispatch.request.parameters']

        ::Honeybadger.notify(
          error,
          tags: tags,
          controller: params[:controller],
          action: params[:action],
          parameters: params
        )
      end

      def shark_error?(error)
        error.is_a?(Errors::Base)
      end
    end
  end
end
