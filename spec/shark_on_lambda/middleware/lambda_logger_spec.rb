# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::LambdaLogger do
  let(:method) { 'POST' }
  let(:headers) do
    {
      'content-type' => 'application/json'
    }
  end
  let(:path) { '/api_gateway?blah=blubb' }
  let(:params) do
    {
      'foo' => 'bar',
      'nested' => %w[value1 value2],
      'deeply_nested' => {
        'next_level' => {
          'key' => 'value'
        }
      }
    }
  end
  let(:env) do
    env_builder = SharkOnLambda::RSpec::EnvBuilder.new(
      method: method,
      headers: headers,
      action: path,
      params: params
    )
    env_builder.build
  end

  let(:log_stream) { StringIO.new }
  let(:log_level) { :info }
  let(:logger) do
    Logger.new(log_stream).tap { |logger| logger.level = log_level }
  end
  let(:instance) do
    SharkOnLambda::Middleware::LambdaLogger.new(
      SharkOnLambda.application,
      logger: logger
    )
  end

  describe '#call' do
    subject(:logged_data) do
      instance.call(env)

      log_stream.rewind
      log_stream.read
    end

    context 'with a log level too high' do
      let(:log_level) { :warn }

      it 'does not log anything' do
        expect(logged_data).to be_empty
      end
    end

    context 'with a log level low enough' do
      let(:log_level) { :info }

      it 'logs the request path' do
        expect(logged_data).to include(%("url":"/api_gateway"))
      end

      it 'logs the request method' do
        expect(logged_data).to include(%("method":"#{method}"))
      end

      it 'logs the request params' do
        expected_params = params.deep_dup
        expected_params[:blah] = 'blubb'
        expected_params.merge!(
          controller: 'test_application/api_gateway',
          action: 'some_action'
        )
        expect(logged_data).to include(%("params":#{expected_params.to_json}))
      end

      it 'logs the response status code' do
        expect(logged_data).to include(%("status":204))
      end

      it 'logs the response body length' do
        expect(logged_data).to include(%("length":0))
      end

      it 'logs the duration' do
        expect(logged_data).to match(/"duration":"\d+\.\d+ ms"/)
      end
    end
  end
end
