# frozen_string_literal: true

module SharkOnLambda
  class ApiGatewayHandler < RackOnLambda::Handlers::RestApi
    def self.call(event:, context:)
      super(event: event, context: context, app: SharkOnLambda.application)
    end
  end
end
