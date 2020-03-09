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
        end_time = Time.now

        if logger.info?
          log_request(env: env,
                      response: response,
                      start_time: start_time,
                      end_time: end_time)
        end

        response
      end

      private

      def body_size(body)
        size = 0
        body.each { |chunk| size += chunk.bytesize }
        size
      end

      def log_request(env:, response:, start_time:, end_time:)
        log_object = {
          url: env['PATH_INFO'],
          method: env['REQUEST_METHOD'],
          params: params(env),
          status: response[0],
          length: body_size(response[2]),
          duration: "#{duration_in_ms(start_time, end_time)} ms"
        }
        logger.info log_object.to_json
      end

      def duration_in_ms(start_time, end_time)
        duration = (end_time - start_time) * 1000
        duration.abs.floor(3)
      end

      def params(env)
        query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
        query_params.merge(env['shark.path_parameters'] || {})
      end
    end
  end
end
