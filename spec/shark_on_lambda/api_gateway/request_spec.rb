# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::Request do
  let(:authorization_header) { 'Bearer asdf' }
  let(:context) { build(:api_gateway_context) }
  let(:base_event) do
    attributes_for(:api_gateway_event).with_indifferent_access
  end
  let(:event) { base_event }

  subject do
    SharkOnLambda::ApiGateway::Request.new(event: event, context: context)
  end

  describe '#authorization' do
    let(:event) { base_event.merge(headers: headers) }

    context 'with the authorization header in "Authorization"' do
      let(:headers) do
        {
          'Authorization' => authorization_header
        }
      end

      it 'returns the authorization header' do
        expect(subject.authorization).to eq(authorization_header)
      end
    end

    context 'with the authorization header in "X-Authorization"' do
      let(:headers) do
        {
          'X-Authorization' => authorization_header
        }
      end

      it 'returns the authorization header' do
        expect(subject.authorization).to eq(authorization_header)
      end
    end

    context 'with the authorization header in "Authorization" and ' \
            '"X-Authorization"' do
      let(:headers) do
        {
          'Authorization' => 'foo',
          'X-Authorization' => 'bar'
        }
      end

      it 'returns the "Authorization" header' do
        expect(subject.authorization).to eq('foo')
      end
    end
  end

  describe '#body' do
    let(:body) { 'Hello, world!' }
    let(:event) { base_event.merge(body: body) }

    it 'returns a StringIO object containing the request body' do
      subject.body.rewind

      expect(subject.body).to be_a(StringIO)
      expect(subject.body.read).to eq(body)
    end
  end

  describe '#content_length' do
    let(:event) { base_event.merge(body: body) }

    context 'without a request body' do
      let(:body) { nil }

      it 'returns 0' do
        expect(subject.content_length).to eq(0)
      end
    end

    context 'with a request body' do
      let(:body) { 'Hello, world! 😱' }

      it 'returns the bytesize of the request body' do
        expect(subject.content_length).to eq(body.bytesize)
      end
    end
  end

  describe '#form_data?' do
    let(:event) { base_event.merge(body: body) }

    context 'without a request body' do
      let(:body) { nil }

      it 'returns false' do
        expect(subject.form_data?).to eq(false)
      end
    end

    context 'with a request body' do
      let(:body) { 'Hello, world! 😱' }

      it 'returns true' do
        expect(subject.form_data?).to eq(true)
      end
    end
  end

  describe '#fullpath' do
    context 'without a query string' do
      let(:query_string_parameters) { {} }
      let(:multi_value_query_string_parameters) { {} }
      let(:event) do
        base_event.merge(
          queryStringParameters: query_string_parameters,
          multiValueQueryStringParameters: multi_value_query_string_parameters
        )
      end

      it 'returns the request path' do
        expect(subject.fullpath).to eq(event[:path])
      end
    end

    context 'with a query string' do
      it 'returns the request path including a query string' do
        expectation = "#{event[:path]}?foo%5B%5D=bar&foo%5B%5D=baz"
        expect(subject.fullpath).to eq(expectation)
      end
    end
  end

  describe '#headers' do
    let(:headers) do
      {
        'Content-Type' => 'application/vnd.api+json',
        'Authorization' => 'Bearer asdf'
      }
    end
    let(:event) { base_event.merge(headers: headers) }

    it 'returns a hash with the headers (keys are lower-case)' do
      expect(subject.headers).to be_a(Hash)
      headers.each_pair do |key, value|
        expect(subject.headers[key.downcase]).to eq(value)
      end
    end
  end

  describe '#ip' do
    it 'returns the right IP address' do
      expect(subject.ip).to eq(event[:requestContext][:identity][:sourceIp])
    end
  end

  describe '#key?' do
    let(:headers) do
      {
        'Authorization' => 'Bearer asdf'
      }
    end
    let(:event) { base_event.merge(headers: headers) }

    context 'with an existing header' do
      it 'returns true' do
        expect(subject.key?('Authorization')).to eq(true)
      end
    end

    context 'with a non-existing header' do
      it 'returns false' do
        expect(subject.key?('Foodib')).to eq(false)
      end
    end
  end

  describe '#local?' do
    let(:event) do
      event = base_event
      event[:requestContext][:identity][:sourceIp] = remote_ip
      event
    end

    context 'with an IP address from a local network' do
      %w[
        127.0.0.1
        ::1
      ].each do |local_address|
        let(:remote_ip) { local_address }

        it 'returns true' do
          expect(subject).to be_local
        end
      end
    end

    context 'with an IP address from a non-local network' do
      %w[
        8.8.8.8
        2046:abcd::1
      ].each do |remote_address|
        let(:remote_ip) { remote_address }

        it 'returns false' do
          expect(subject).to_not be_local
        end
      end
    end
  end

  describe '#media_type' do
    let(:headers) do
      {
        'Content-Type' => 'application/vnd.api+json'
      }
    end
    let(:event) { base_event.merge(headers: headers) }

    it 'returns the "Content-Type" header' do
      expect(subject.media_type).to eq(headers['Content-Type'])
    end
  end

  describe '#method' do
    it 'returns the HTTP method of the request' do
      expect(subject.method).to eq('GET')
    end
  end

  describe '#method_symbol' do
    it 'returns the HTTP method of the request as a (downcase) symbol' do
      expect(subject.method_symbol).to eq(:get)
    end
  end

  describe '#original_url' do
    it 'returns the full URI of the request' do
      expectation = 'https://test.local/api/v1/mailing/1234' \
                    '?foo%5B%5D=bar&foo%5B%5D=baz'
      expect(subject.original_url).to eq(expectation)
    end
  end

  describe '#path_parameters' do
    context 'without any path parameters' do
      let(:event) { base_event.merge(pathParameters: {}) }

      it 'returns an empty hash' do
        expect(subject.path_parameters).to eq({})
      end
    end

    context 'with path parameters' do
      it 'returns a hash containing all path parameters' do
        expect(subject.path_parameters).to eq('id' => '1234')
      end
    end
  end

  describe '#query_parameters' do
    context 'without any query string parameters' do
      let(:event) do
        base_event.merge(
          queryStringParameters: {},
          multiValueQueryStringParameters: {}
        )
      end

      it 'returns an empty hash' do
        expect(subject.query_parameters).to eq({})
      end
    end

    context 'with query string parameters' do
      it 'returns a hash containing all query string parameters' do
        expectation = {
          'foo' => %w[bar baz]
        }
        expect(subject.query_parameters).to eq(expectation)
      end
    end
  end

  describe '#raw_post' do
    context 'without a request body' do
      it 'returns nil' do
        expect(subject.raw_post).to be_nil
      end
    end

    context 'with a request body' do
      let(:body) { 'Hello, world!' }
      let(:event) { base_event.merge(body: body) }

      it 'returns the request body' do
        expect(subject.raw_post).to eq(body)
      end

      context 'encoded as Base64' do
        let(:event) do
          base_event.merge(
            body: Base64.encode64(body),
            isBase64Encoded: true
          )
        end

        it 'returns the decoded request body' do
          expect(subject.raw_post).to eq(body)
        end
      end
    end
  end

  describe '#request_parameters' do
    let(:event) { base_event.merge(body: body) }

    context 'with no request body' do
      let(:body) { nil }

      it 'returns an empty hash' do
        expect(subject.request_parameters).to eq({})
      end
    end

    context 'with non-JSON body' do
      let(:body) { 'Hello, world!' }

      it 'throws a "Bad Request" exception' do
        expectation = SharkOnLambda::ApiGateway::Errors[400]
        expect { subject.request_parameters }.to raise_error(expectation)
      end
    end

    context 'with a non-object JSON body' do
      let(:body) { '[]' }

      it 'throws a "Bad Request" exception' do
        expectation = SharkOnLambda::ApiGateway::Errors[400]
        expect { subject.request_parameters }.to raise_error(expectation)
      end
    end

    context 'with a valid JSON body' do
      let(:payload) do
        {
          'data' => {
            'id' => '1234',
            'type' => 'items',
            'attributes' => ''
          }
        }
      end
      let(:body) { payload.to_json }

      it 'returns a hash contaning the payload' do
        expect(subject.request_parameters).to eq(payload)
      end
    end
  end

  describe '#xml_http_request?' do
    let(:event) { base_event.merge(headers: headers) }

    context 'with no "X-Requested-With" header set' do
      let(:headers) { {} }

      it 'returns false' do
        expect(subject.xml_http_request?).to eq(false)
      end
    end

    context 'with a non-XHR "X-Requested-With" header set' do
      let(:headers) do
        {
          'X-Requested-With' => 'Something'
        }
      end

      it 'returns false' do
        expect(subject.xml_http_request?).to eq(false)
      end
    end

    context 'with an XHR "X-Requested-With" header set' do
      %w[
        xmlhttprequest
        XmlHttpRequest
        XMLHttpRequest
      ].each do |xhr_header|
        let(:headers) do
          {
            'X-Requested-With' => xhr_header
          }
        end

        it 'returns true' do
          expect(subject.xml_http_request?).to eq(true)
        end
      end
    end
  end
end
