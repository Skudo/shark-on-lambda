# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module ResponseHelpers
      def jsonapi_attributes
        jsonapi_data.fetch(:attributes, {})
      end

      def jsonapi_data
        parsed_body.fetch(:data, {})
      end

      def jsonapi_errors
        parsed_body.fetch(:errors, [])
      end

      private

      def parsed_body
        @parsed_body ||= JSON.parse(response.body).with_indifferent_access
      end
    end
  end
end
