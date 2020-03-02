# frozen_string_literal: true

module SharkOnLambda
  class Application
    def call(env)
      dup.send('_call', env)
    end

    private

    def _call(env)
      dispatcher = SharkOnLambda.config.dispatcher
      middleware_stack = SharkOnLambda.config.middleware.build(dispatcher)
      middleware_stack.call(env)
    end
  end
end
