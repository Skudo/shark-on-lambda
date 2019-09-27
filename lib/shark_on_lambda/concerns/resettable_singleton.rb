# frozen_string_literal: true

module SharkOnLambda
  module Concerns
    # Decorates the *Singleton* module with a *.reset* class method to
    # destroy the existing singleton instance.
    module ResettableSingleton
      # @!visibility protected
      def self.included(base)
        base.include(Singleton)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Resets the singleton instance.
        def reset
          @singleton__instance__ = nil
        end
      end
    end
  end
end
