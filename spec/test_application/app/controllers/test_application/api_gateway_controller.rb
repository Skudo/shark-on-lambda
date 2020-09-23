# frozen_string_literal: true

module TestApplication
  class ApiGatewayController < SharkOnLambda::BaseController
    def create; end

    def index
      render plain: 'Hello, world!'
    end

    def shark_error
      raise SharkOnLambda::Errors[403], 'You shall not pass!'
    end

    def unknown_error
      raise StandardError, 'Something unexpected happened?'
    end
  end
end
