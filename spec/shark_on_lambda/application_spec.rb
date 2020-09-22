# frozen_string_literal: true

RSpec.describe SharkOnLambda::Application do
  shared_examples 'behaves like a Rack app' do
    it 'eventually calls the dispatcher' do
      expect(application.routes).to receive(:call)
      subject
    end

    it 'returns a Rack-compatible response' do
      status, headers, body = subject

      expect(status).to be_present
      expect(headers).to be_a(Hash)
      expect(body).to be_present
      expect(body).to be_an(Enumerable)
    end
  end

  let(:dispatcher_response) { Rack::MockResponse.new(200, {}, 'Hello!').to_a }
  let(:env) { {} }

  let(:application) { SharkOnLambda.application }

  before do
    allow(application.routes).to receive(:call).and_return(dispatcher_response)
  end

  describe '#call' do
    subject { application.call(env) }

    context 'without using any middleware' do
      include_examples 'behaves like a Rack app'
    end

    context 'using middleware' do
      let(:middleware) { SharkOnLambda::Middleware::JsonapiRescuer }

      before { application.middleware.use(middleware) }

      it 'uses the middleware' do
        expect_any_instance_of(middleware).to receive(:call).and_call_original
        subject
      end

      include_examples 'behaves like a Rack app'
    end
  end

  describe '#config_for' do
    context 'with existing configuration files' do
      subject { application.config_for(:settings) }

      it 'loads the right configuration' do
        expected_configuration = {
          credentials: {
            password: 'secret-password'
          },
          host: 'test.example.com',
          port: 8443
        }.with_indifferent_access

        expect(subject).to eq(expected_configuration)
      end
    end

    context 'without existing configuration files' do
      subject { application.config_for(:does_not_exist) }

      it 'raises an exception' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
