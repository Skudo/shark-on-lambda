# frozen_string_literal: true

module SharkOnLambda
  class Request < ActionDispatch::Request
    def path_parameters
      super.merge(env['shark.path_parameters'] || {})
    end
  end
end
