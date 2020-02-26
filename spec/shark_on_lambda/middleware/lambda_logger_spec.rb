# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::LambdaLogger do
  let!(:method) { 'POST' }
  let!(:path) { '/hello/world' }
  let!(:params) do
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
  let!(:path_parameters) do
    {
      'id' => 3,
      'parent_id' => 1
    }
  end
  let!(:env) do
    {
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path,
      'QUERY_STRING' => Rack::Utils.build_nested_query(params),
      'shark.path_parameters' => path_parameters
    }
  end

  let!(:status) { 200 }
  let!(:headers) { {} }
  let!(:body) { 'Hello, world!' }
  let!(:response) { [status, headers, [body]] }
  let!(:app) { ->(_env) { response } }

  let!(:log_stream) { StringIO.new }
  let!(:log_level) { :info }
  let!(:logger) do
    Logger.new(log_stream).tap { |logger| logger.level = log_level }
  end
  let!(:instance) do
    SharkOnLambda::Middleware::LambdaLogger.new(app, logger: logger)
  end

  describe '#call' do
    let!(:logged_data) do
      instance.call(env)

      log_stream.rewind
      log_stream.read
    end

    it 'returns the response without modifying it' do
      expect(instance.call(env)).to eq(response)
    end

    context 'with a log level too high' do
      let!(:log_level) { :warn }

      it 'does not log anything' do
        expect(logged_data).to be_empty
      end
    end

    context 'with a log level low enough' do
      let!(:log_level) { :info }

      it 'logs the request path' do
        expect(logged_data).to include(%("url":"#{path}"))
      end

      it 'logs the request method' do
        expect(logged_data).to include(%("method":"#{method}"))
      end

      it 'logs the request params' do
        expected_params = params.merge(path_parameters).to_json

        expect(logged_data).to include(%("params":#{expected_params}))
      end

      it 'logs the response status code' do
        expect(logged_data).to include(%("status":#{status}))
      end

      it 'logs the response body length' do
        expect(logged_data).to include(%("length":#{body.bytesize}))
      end

      it 'logs the duration' do
        expect(logged_data).to match(/"duration":"\d+\.\d+ ms"/)
      end
    end
  end
end
