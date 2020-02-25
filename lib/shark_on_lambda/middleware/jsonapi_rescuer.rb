# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class JsonapiRescuer < Rescuer
      private

      def error_object(status, message)
        {
          status: status.to_s,
          title: Rack::Utils::HTTP_STATUS_CODES[status],
          detail: message
        }
      end

      def error_response(status, headers, message)
        body = {
          errors: [
            error_object(status, message)
          ]
        }.to_json

        response_body = Rack::BodyProxy.new([body]) do
          message.close if message.respond_to?(:close)
        end

        [status, headers, response_body]
      end
    end
  end
end
