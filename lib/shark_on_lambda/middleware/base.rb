# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Base
      attr_reader :app

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        dup.call!(env)
      end

      def call!(_env)
        raise NotImplementedError
      end
    end
  end
end
