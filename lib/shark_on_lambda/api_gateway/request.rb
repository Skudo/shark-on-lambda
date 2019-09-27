# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class Request
      attr_reader :event, :context

      LOCALHOST = Regexp.union([/^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$/,
                                /^::1$/,
                                /^0:0:0:0:0:0:0:1(%.*)?$/]).freeze

      def initialize(event:, context:)
        @event = event
        @context = context
        @headers = Headers.new

        event['headers']&.each { |key, value| @headers[key] = value }
      end

      def authorization
        @headers['authorization'] || @headers['x-authorization']
      end

      def body
        StringIO.new(raw_post)
      end

      def content_length
        raw_post.present? ? raw_post.bytesize : 0
      end

      def form_data?
        raw_post.present?
      end

      # This method does not necessarily return the full path the client sent
      # for the request: AWS API Gateway does not provide such an attribute.
      # We therefore put together the query string using the
      # event['multiValueQueryStringParameters'] property and return a path
      # that is for almost all purposes equivalent to the client's request path.
      # But keep in mind it is NOT the same!
      def fullpath
        return @fullpath if defined?(@fullpath)

        uri = URI.parse(event['requestContext']['path'])
        uri.query = query_string if query_string.present?
        @fullpath = uri.to_s
      end
      alias original_fullpath fullpath

      def headers
        @headers.to_h
      end

      def ip
        event['requestContext']['identity']['sourceIp']
      end
      alias remote_ip ip

      def key?(key)
        @headers.key?(key)
      end

      def local?
        (LOCALHOST =~ remote_ip).present?
      end

      def media_type
        @headers['content-type']
      end

      def method
        event['httpMethod']
      end
      alias request_method method

      def method_symbol
        return nil if method.blank?

        method.downcase.to_sym
      end
      alias request_method_symbol method_symbol

      def original_url
        hostname = event['requestContext']['domainName']
        uri = URI.join("https://#{hostname}", original_fullpath)
        uri.to_s
      end

      def path_parameters
        return @path_parameters if defined?(@path_parameters)

        @path_parameters = HashWithIndifferentAccess.new
        @path_parameters = @path_parameters.merge(event['pathParameters'] || {})
      end

      def query_parameters
        return @query_parameters if defined?(@query_parameters)

        # We have to jump through the Rack::Utils hoops here, because the event
        # object from the AWS Gateway deserialises the query string in a "wrong"
        # way, so we need to put it back together and deserialise it with
        # Rack::Utils.parse_nested_query.
        data = Rack::Utils.parse_nested_query(query_string)
        @query_parameters = HashWithIndifferentAccess.new
        @query_parameters = @query_parameters.merge(data)
      end
      alias GET query_parameters

      def raw_post
        return @raw_post if defined?(@raw_post)

        @raw_post = event['body']
        @raw_post = Base64.decode64(@raw_post) if event['isBase64Encoded']
        @raw_post
      end

      def request_parameters
        return @request_parameters if defined?(@request_parameters)
        return {} if raw_post.blank?

        data = JSON.parse(raw_post)
        @request_parameters = HashWithIndifferentAccess.new
        @request_parameters = @request_parameters.merge(data)
      rescue JSON::ParserError => e
        raise Errors[400], e.message
      rescue StandardError
        raise Errors[400], 'The request body must be empty or a JSON object.'
      end
      alias POST request_parameters

      def xml_http_request?
        (headers['x-requested-with'] =~ /XMLHttpRequest/i).present?
      end
      alias xhr? xml_http_request?

      protected

      def query_string
        return @query_string if defined?(@query_string)

        query_string_parameters = event['multiValueQueryStringParameters'] || {}
        @query_string = ::Rack::Utils.build_query(query_string_parameters)
      end
    end
  end
end
