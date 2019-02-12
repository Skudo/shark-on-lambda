# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::Response do
  let(:headers) { SharkOnLambda::ApiGateway::Headers.new }

  subject { SharkOnLambda::ApiGateway::Response.new(headers: headers) }

  describe '.default_charset' do
    subject { SharkOnLambda::ApiGateway::Response.default_charset }

    it 'returns the default charset' do
      expect(subject).to eq('utf-8')
    end
  end

  describe '.default_content_type' do
    subject { SharkOnLambda::ApiGateway::Response.default_content_type }

    it 'returns the default content type' do
      expect(subject).to eq('application/vnd.api+json')
    end
  end

  describe '.new' do
    it 'returns a default response object' do
      expected_headers = {
        'content-type' => subject.class.default_content_type
      }
      expect(subject.response_code).to eq(200)
      expect(subject.headers.to_h).to eq(expected_headers)
      expect(subject.content_type).to eq(subject.class.default_content_type)
      expect(subject.charset).to eq(subject.class.default_charset)
      expect(subject.body).to be_nil
    end
  end

  describe '#delete_header' do
    let(:key) { 'foo' }

    it 'deletes the given header' do
      expect(headers).to receive(:delete).with(key).once
      subject.delete_header(key)
    end
  end

  describe '#get_header' do
    let(:key) { 'foo' }

    it 'retrieves the given header' do
      expect(headers).to receive(:[]).with(key).once
      subject.get_header(key)
    end
  end

  describe '#has_header?' do
    let(:key) { 'foo' }

    it 'checks if the given header exists' do
      expect(headers).to receive(:key?).with(key).once
      subject.has_header?(key)
    end
  end

  describe '#message' do
    it 'returns a human-readable message for the response code' do
      ::Rack::Utils::HTTP_STATUS_CODES.each_pair do |status, message|
        subject.status = status
        expect(subject.message).to eq(message)
      end
    end
  end

  describe '#response_code' do
    it 'returns the HTTP status code for the response' do
      subject.status = 415
      expect(subject.response_code).to eq(415)
    end
  end

  describe '#set_header' do
    let(:key) { 'foo' }
    let(:value) { 'bar' }

    it 'sets the given header' do
      subject
      expect(headers).to receive(:[]=).with(key, value).once
      subject.set_header(key, value)
    end
  end

  describe '#to_h' do
    context 'without a response body' do
      context 'and a status code representing an empty body response' do
        it 'returns that status code and no body' do
          [204, 304].each do |status_code|
            subject.status = status_code
            response = subject.to_h
            expect(response[:statusCode]).to eq(status_code)
            expect(response[:body]).to be_nil
          end
        end
      end

      context 'and a status code representing a non-empty 2xx body response' do
        it 'returns a 204 status code and no body' do
          [200, 201, 202].each do |status_code|
            subject.status = status_code
            response = subject.to_h
            expect(response[:statusCode]).to eq(204)
            expect(response[:body]).to be_nil
          end
        end
      end

      context 'and a status code representing a non-empty 3xx body response' do
        it 'returns a 304 status code and no body' do
          [300, 301, 302].each do |status_code|
            subject.status = status_code
            response = subject.to_h
            expect(response[:statusCode]).to eq(304)
            expect(response[:body]).to be_nil
          end
        end
      end
    end

    context 'with a response body' do
      let(:body) { 'Hello, world!' }
      subject do
        response = SharkOnLambda::ApiGateway::Response.new(headers: headers)
        response.body = body
        response
      end

      context 'and a status code representing an empty body response' do
        it 'returns that status code and no body' do
          [100, 204, 304].each do |status_code|
            subject.status = status_code
            response = subject.to_h
            expect(response[:statusCode]).to eq(status_code)
            expect(response[:body]).to be_nil
          end
        end
      end

      context 'and a status code representing a non-empty body response' do
        it 'returns the original status code and the body' do
          [200, 201, 202, 300, 301, 302].each do |status_code|
            subject.status = status_code
            response = subject.to_h
            expect(response[:statusCode]).to eq(status_code)
            expect(response[:body]).to eq(body)
          end
        end
      end
    end
  end
end
