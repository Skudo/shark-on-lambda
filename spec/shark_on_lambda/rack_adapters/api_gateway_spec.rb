# frozen_string_literal: true

RSpec.describe SharkOnLambda::RackAdapters::ApiGateway do
  let!(:context) { attributes_for(:api_gateway_context) }
  let!(:event) { attributes_for(:api_gateway_event).deep_stringify_keys }

  let!(:instance) do
    SharkOnLambda::RackAdapters::ApiGateway.new(context: context, event: event)
  end

  describe '#build_response' do
    let!(:status) { 200 }
    let!(:headers) { {} }
    let!(:body) { 'Hello, world!' }
    let!(:body_proxy) do
      Rack::BodyProxy.new([body]) do
      end
    end

    subject { instance.build_response(status, headers, body_proxy) }

    context 'with a request from an ELB' do
      let!(:event) do
        attributes = attributes_for(:api_gateway_event)
        attributes[:requestContext].merge!(elb: true)
        attributes.deep_stringify_keys
      end

      it 'builds an API Gateway response' do
        expect(subject['statusCode']).to eq(status)
        expect(subject['headers']).to eq(headers)
        expect(subject['body']).to eq(body)
      end

      it 'sets the `isBase64Encoded` attribute' do
        expect(subject['isBase64Encoded']).to eq(false)
      end
    end

    it 'builds an API Gateway response' do
      expect(subject['statusCode']).to eq(status)
      expect(subject['headers']).to eq(headers)
      expect(subject['body']).to eq(body)
    end
  end

  describe '#env' do
    subject(:env) { instance.env }

    context 'with a base64 encoded body' do
      let!(:plain_text_body) { 'Hello, world!' }
      let!(:event) do
        attributes = attributes_for(:api_gateway_event,
                                    body: Base64.encode64(plain_text_body),
                                    isBase64Encoded: true)
        attributes.deep_stringify_keys
      end

      it 'contains the request body' do
        expect(env['rack.input']).to be_a(StringIO)
        expect(env['rack.input'].read).to eq(plain_text_body)
      end
    end

    context 'with a plain text body' do
      it 'contains the request body' do
        expect(env['rack.input']).to be_a(StringIO)
        expect(env['rack.input'].read).to eq(event['body'])
      end
    end

    it 'contains all HTTP headers' do
      headers = event['headers'] || {}

      expect(env['CONTENT_LENGTH']).to eq(headers['Content-Length'].to_s)
      expect(env['CONTENT_TYPE']).to eq(headers['Content-Type'])
      expect(env['HTTP_ACCEPT_ENCODING']).to eq(headers['Accept-Encoding'])
      expect(env['HTTP_AUTHORIZATION']).to eq(headers['Authorization'])
    end

    it 'contains the HTTP request method' do
      expect(env['REQUEST_METHOD']).to eq(event['httpMethod'])
    end

    it 'contains the HTTP request path' do
      expect(env['PATH_INFO']).to eq(event['path'])
    end

    it 'contains the query string' do
      expected_query_string = 'foo=foo&bar[]=bar&bar[]=baz&' \
                              'top%5Bnested%5D%5Bnested_value%5D=value&' \
                              'top%5Bnested%5D%5Bnested_array%5D[]=1'

      expect(env['QUERY_STRING']).to eq(expected_query_string)
    end

    it 'contains all path parameters' do
      expect(env['shark.path_parameters']).to eq(event['pathParameters'])
    end

    it 'contains the server name' do
      expect(env['SERVER_NAME']).to eq('localhost')
    end

    it 'contains the server port' do
      expect(env['SERVER_PORT']).to eq('443')
    end

    it 'contains the URI schema' do
      expect(env['rack.url_scheme']).to eq('https')
    end
  end
end
