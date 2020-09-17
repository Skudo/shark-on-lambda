# frozen_string_literal: true

module TestApplication
  class ApiGatewayController < SharkOnLambda::BaseController
    def index
      render plain: 'Hello, world!'
    end
  end
end
