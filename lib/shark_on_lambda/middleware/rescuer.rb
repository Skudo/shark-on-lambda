# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Rescuer < Base
      def call!(env)
        app.call(env)
      rescue Errors::Base => e
        rescue_shark_error(e)
      rescue StandardError => e
        rescue_standard_error(e)
      end

      private

      def error_response(status, headers, message)
        response_body = Rack::BodyProxy.new([message]) do
          message.close if message.respond_to?(:close)
        end

        [status, headers, response_body]
      end

      def rescue_shark_error(error)
        status = error.status || 500
        error_response(status, {}, error.message)
      end

      def rescue_standard_error(error)
        SharkOnLambda.logger.error(error.message)
        SharkOnLambda.logger.error(error.backtrace.join("\n"))

        error_response(500, {}, error.message)
      end
    end
  end
end
