# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class Parameters
      extend Forwardable

      def initialize(request)
        @params = ::HashWithIndifferentAccess.new
        @params = @params.merge(request.request_parameters)
        @params = @params.merge(request.query_parameters)
        @params = @params.merge(request.path_parameters)
      end

      def_instance_delegators :@params, :[], :as_json
    end
  end
end
