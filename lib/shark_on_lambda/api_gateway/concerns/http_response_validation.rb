# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    module Concerns
      # Provides methods for HTTP-related validation, e. g. for status codes
      # and URIs. If validation fails, question mark methods return *false*,
      # exclamation mark methods raise an exception.
      #
      # TODO: Specs for this module.
      module HttpResponseValidation
        # Validates a URL.
        #
        # @param url [String] The URL to validate.
        # @return [TrueClass] If the URL is valid and present.
        # @return [FalseClass] If the URL is invalid or blank.
        def valid_url?(url)
          URI.parse(url.to_s)
          url.present?
        rescue URI::InvalidURIError
          false
        end

        # Validates a HTTP redirection status code.
        #
        # @param status [Number] The HTTP status code to validate.
        # @return [NilClass] Returns *nil* if *status* is valid.
        # @raise [Errors::InternalServerError] If the status code does not
        #                                      represent a HTTP redirection.
        def validate_redirection_status!(status)
          validate_response_status!(status)
          return if (300..399).cover?(status)

          raise Errors[500], 'HTTP redirections must have a 3xx status code.'
        end

        # Validates a HTTP status code.
        #
        # @param status [Number] The HTTP status code to validate.
        # @return [NilClass] Returns *nil* if *status* is valid.
        # @raise [Errors::InternalServerError] If the status code is unknown.
        def validate_response_status!(status)
          return if ::Rack::Utils::HTTP_STATUS_CODES[status].present?

          raise Errors[500], 'Unknown response status code.'
        end

        # Validates a URL.
        #
        # @param url [String] The URL to validate.
        # @return [NilClass] Returns *nil* if *url* is valid.
        # @raise [Errors::InternalServerError] If the URL is invalid.
        def validate_url!(url)
          return if valid_url?(url)

          raise Errors[500], "`#{url}' is not a valid URL."
        end
      end
    end
  end
end
