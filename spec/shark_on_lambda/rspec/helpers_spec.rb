# frozen_string_literal: true

RSpec.describe SharkOnLambda::RSpec::Helpers do
  let(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::RSpec::Helpers

      def described_class
        TestApplication::ApiGatewayController
      end
    end
  end

  let(:action) { 'some_action' }

  let(:request_headers) do
    {
      'Accept-Encoding': 'br, gzip, deflate',
      'Content-Type': 'text/plain'
    }
  end
  let(:request_params) do
    {
      id: 1,
      type: 'things',
      foo: 'bar',
      baz: 'blubb'
    }
  end

  let(:response_status) { 200 }
  let(:response_body) { 'Hello, world!' }
  let(:response_headers) do
    {
      'Content-Length' => response_body.bytesize,
      'Content-Type' => 'text/plain'
    }
  end
  let(:response) { [response_status, response_headers, [response_body]] }

  before do
    allow(SharkOnLambda.application.routes).to(
      receive(:call).and_return(response)
    )
  end

  let(:instance) { class_with_mixin.new }

  %w[delete get patch post put].each do |http_verb|
    describe "##{http_verb.upcase}" do
      let(:env_without_streams) do
        builder = SharkOnLambda::RSpec::EnvBuilder.new(
          method: http_verb.upcase,
          controller: instance.described_class,
          action: action,
          headers: request_headers,
          params: request_params
        )
        builder.build.reject { |key, _| key.in?(%w[rack.errors rack.input]) }
      end

      subject do
        instance.send(
          http_verb,
          action,
          headers: request_headers,
          params: request_params
        )
      end

      context 'without a "content-type" header' do
        let(:request_headers) do
          {
            'Accept-Encoding': 'br, gzip, deflate'
          }
        end

        it 'sets a default "content-type" header' do
          expected_env = env_without_streams
          expected_env['CONTENT_TYPE'] = 'application/vnd.api+json'

          expect(SharkOnLambda.application).to(
            receive(:call)
              .with(hash_including(expected_env))
              .and_call_original
          )
          subject
        end
      end

      context 'with a "content-type" header' do
        it 'uses the given "content-type" header' do
          expected_env = env_without_streams

          expect(SharkOnLambda.application).to(
            receive(:call)
              .with(hash_including(expected_env))
              .and_call_original
          )
          subject
        end
      end

      context 'without the "skip_middleware" parameter' do
        it 'calls the middleware stack with the right "env" object' do
          expect(SharkOnLambda.application).to(
            receive(:call)
              .with(hash_including(env_without_streams))
              .and_call_original
          )
          subject
        end

        it 'dispatches the right "env" object' do
          expect(SharkOnLambda.application).to(
            receive(:call).with(hash_including(env_without_streams))
          ).and_call_original
          subject
        end
      end

      it 'generates a response with the right status code' do
        subject
        expect(instance.response.status).to eq(response_status)
      end

      it 'generates a response with the right headers' do
        subject
        expect(instance.response.headers).to eq(response_headers)
      end

      it 'generates a response with the right body' do
        subject
        expect(instance.response.body).to eq(response_body)
      end
    end
  end

  describe '#response' do
    subject { instance.response }

    context 'without having made a request before' do
      it 'raises a RuntimeError exception' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'after a request had been made' do
      it 'returns the response object' do
        instance.get :index

        expect(subject).to be_a(::Rack::MockResponse)
      end
    end
  end
end
