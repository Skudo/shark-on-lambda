# frozen_string_literal: true

module SharkOnLambda
  module RSpec
    module JsonapiHelpers
      include Helpers

      def jsonapi_attributes
        jsonapi_data[:attributes] || {}
      end

      def jsonapi_data
        parsed_body[:data] || {}
      end

      def jsonapi_errors
        parsed_body[:errors] || []
      end

      private

      def default_content_type
        'application/vnd.api+json'
      end

      def parsed_body
        @parsed_body ||= JSON.parse(response.body).with_indifferent_access
      end
    end
  end
end
