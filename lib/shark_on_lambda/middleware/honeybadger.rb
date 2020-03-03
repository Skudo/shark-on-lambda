# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Honeybadger < Base
      attr_reader :tags

      def initialize(app, tags: '')
        super(app)

        @tags = tags
      end

      private

      def _call(env)
        @env = env
        app.call(env)
      rescue StandardError => e
        notify(e) unless shark_error?(e)

        raise e
      end

      def notify(error)
        ::Honeybadger.notify(
          error,
          tags: tags,
          controller: @env['shark.controller'],
          action: @env['shark.action'],
          parameters: @env['action_dispatch.request.parameters']
        )
      end

      def shark_error?(error)
        error.is_a?(Errors::Base)
      end
    end
  end
end
