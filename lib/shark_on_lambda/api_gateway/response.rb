# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class Response
      attr_accessor :body, :charset, :content_type
      attr_reader :headers
      attr_writer :status

      STATUS_WITH_NO_ENTITY_BODY = ((100..199).to_a + [204, 304]).freeze

      def self.default_charset
        'utf-8'
      end

      def self.default_content_type
        'application/vnd.api+json'
      end

      def initialize(headers: nil)
        @body = nil
        @charset = self.class.default_charset
        @content_type = self.class.default_content_type
        @headers = headers || Headers.new
        @headers['content-type'] = self.class.default_content_type
        @status = 200
      end

      def delete_header(key)
        @headers.delete(key)
      end

      def get_header(key)
        @headers[key]
      end

      # rubocop:disable Naming/PredicateName
      def has_header?(key)
        @headers.key?(key)
      end
      # rubocop:enable Naming/PredicateName

      def message
        ::Rack::Utils::HTTP_STATUS_CODES[@status]
      end
      alias status_message message

      def response_code
        @status
      end

      def set_header(key, value)
        @headers[key] = value
      end

      def to_h
        {
          statusCode: response_status_code,
          headers: headers.to_h,
          body: response_body
        }
      end

      protected

      def response_status_code
        return @status.to_i if response_body.present?
        return 204 if (200..299).cover?(@status.to_i)
        return 304 if (300..399).cover?(@status.to_i)

        @status.to_i
      end

      def response_body
        return if STATUS_WITH_NO_ENTITY_BODY.include?(@status)
        return if body.blank?

        body.is_a?(String) ? body : body.to_json
      end
    end
  end
end
