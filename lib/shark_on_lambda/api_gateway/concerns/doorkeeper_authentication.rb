# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    module DoorkeeperAuthentication
      include ::Doorkeeper::Authentication

      protected

      attr_reader :current_user

      def authenticate!
        raise Errors[403], 'Invalid credentials.' unless service_token_valid?

        @current_user = service_token_user
      end
    end
  end
end
