# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class LambdaLogger < Base
      attr_reader :logger

      def initialize(app, logger: SharkOnLambda.logger)
        super(app)
        @logger = logger
      end

      def call!(env)
        start_time = Time.now
        response = app.call(env)
        duration = duration_in_ms(start_time, Time.now)

        if logger.info?
          log_request(env: env, response: response, duration: duration)
        end

        response
      end

      private

      def body_size(body)
        size = 0
        body.each { |chunk| size += chunk.bytesize }
        size
      end

      def log_request(env:, response:, duration:)
        log_object = {
          url: env['PATH_INFO'],
          method: env['REQUEST_METHOD'],
          params: env['action_dispatch.request.parameters'] || {},
          status: response[0],
          length: body_size(response[2]),
          duration: "#{duration} ms"
        }
        logger.info log_object.to_json
      end

      def duration_in_ms(start_time, end_time)
        duration = (end_time - start_time) * 1000
        duration.abs.floor(3)
      end
    end
  end
end
