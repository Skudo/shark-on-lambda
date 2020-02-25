# frozen_string_literal: true

module SharkOnLambda
  class Dispatcher
    def call(env)
      request = Request.new(env)
      response = Response.new

      controller = controller_class(env)
      action = controller_action(env)
      controller.dispatch(action, request, response)

      response.prepare!
    end

    private

    def controller_action(env)
      env['shark.action']
    end

    def controller_class(env)
      env['shark.controller'].camelize.constantize
    end
  end
end
