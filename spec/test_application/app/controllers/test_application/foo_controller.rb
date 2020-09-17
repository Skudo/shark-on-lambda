# frozen_string_literal: true

module TestApplication
  class FooController < SharkOnLambda::BaseController
    def index
      render plain: 'Hello, world!'
    end

    def some_action
      render plain: 'Hello, world!'
    end
  end
end
