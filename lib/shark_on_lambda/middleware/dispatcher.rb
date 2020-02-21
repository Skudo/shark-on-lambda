# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Dispatcher < Base
      private

      def _call(env)
        request = Request.new(env)
        response = Response.new

        controller = controller_class(env)
        action = controller_action(env)
        controller.dispatch(action, request, response)

        response.prepare!
      end

      def controller_action(env)
        env['shark.action']
      end

      def controller_class(env)
        env['shark.controller'].camelize.constantize
      end
    end
  end
end
