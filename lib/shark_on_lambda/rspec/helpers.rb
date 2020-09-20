# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module Helpers
      extend ActiveSupport::Concern
      include RequestHelpers
      include ResponseHelpers

      included do
        include SharkOnLambda.application.routes.url_helpers
      end
    end
  end
end
