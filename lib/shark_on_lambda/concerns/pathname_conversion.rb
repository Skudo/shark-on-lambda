# frozen_string_literal: true

module SharkOnLambda
  module Concerns
    module PathnameConversion
      def pathname(path)
        case path
        when Pathname then path
        when String then Pathname.new(path)
        else raise ArgumentError, "`path' must be a String or a Pathname."
        end
      end
    end
  end
end
