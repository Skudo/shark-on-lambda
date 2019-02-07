# frozen_string_literal: true

module SharkOnLambda
  module ResettableSingleton
    def self.included(base)
      base.include(Singleton)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def reset
        @singleton__instance__ = nil
      end
    end
  end
end
