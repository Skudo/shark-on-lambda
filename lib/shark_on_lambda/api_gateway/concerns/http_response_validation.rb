# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    module HttpResponseValidation
      def valid_redirection_url?(url)
        URI.parse(url.to_s)
        url.present?
      rescue URI::InvalidURIError
        false
      end

      def validate_response_status!(status)
        return if ::Rack::Utils::HTTP_STATUS_CODES[status].present?

        raise Errors[500], 'Unknown response status code.'
      end

      def validate_redirection_status!(status)
        validate_response_status!(status)
        return if (300..399).cover?(status)

        raise Errors[500], 'HTTP redirections must have a 3xx status code.'
      end

      def validate_redirection_url!(url)
        return if valid_redirection_url?(url)

        raise Errors[500], "`#{url}' is not a valid redirection target."
      end
    end
  end
end
