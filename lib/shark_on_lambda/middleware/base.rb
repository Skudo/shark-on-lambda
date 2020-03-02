# frozen_string_literal: true

module SharkOnLambda
  module Middleware
    class Base
      attr_reader :app

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        dup.send('_call', env)
      end

      private

      def _call(_env)
        raise NotImplementedError
      end
    end
  end
end
