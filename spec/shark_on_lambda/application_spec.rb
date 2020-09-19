# frozen_string_literal: true

RSpec.describe SharkOnLambda::Application do
  let(:body) do
    Rack::BodyProxy.new(['Hello, world!']) do
    end
  end
  let(:dispatcher_response) { [200, {}, body] }
  let(:env) do
    {
      'REQUEST_METHOD' => 'GET'
    }
  end

  let(:application) { SharkOnLambda.application }

  before do
    allow(SharkOnLambda.application.routes).to(
      receive(:call).and_return(dispatcher_response)
    )
  end

  describe '#call' do
    subject { application.call(env) }

    context 'without using any middleware' do
      it 'eventually calls the dispatcher' do
        expect(SharkOnLambda.application.routes).to(receive(:call))

        subject
      end

      it 'returns a Rack-compatible response' do
        status, headers, body = subject

        expect(status).to be_present
        expect(headers).to be_a(Hash)
        expect(body).to be_present
      end

      it 'returns a closable body' do
        _, _, body_proxy = subject

        expect { body_proxy.close }.to_not raise_error
      end
    end

    context 'using middleware' do
      before do
        # Doing the obvious
        #
        #     SharkOnLambda.application.middleware.use(
        #       SharkOnLambda::Middleware::Rescuer
        #     )
        #
        # does not work, because it throws an error:
        #
        #     FrozenError: can't modify frozen Array
        #
        stack = ActionDispatch::MiddlewareStack.new
        stack.use(SharkOnLambda::Middleware::Rescuer)
        allow(SharkOnLambda.application).to(
          receive(:middleware).and_return(stack)
        )
      end

      it 'eventually calls the dispatcher' do
        expect(SharkOnLambda.application.routes).to(receive(:call))

        subject
      end

      it 'returns a Rack-compatible response' do
        status, headers, body = subject

        expect(status).to be_present
        expect(headers).to be_a(Hash)
        expect(body).to be_present
      end

      it 'returns a closable body' do
        _, _, body_proxy = subject

        expect { body_proxy.close }.to_not raise_error
      end
    end
  end

  describe '#config_for' do
    context 'with existing configuration files' do
      subject { application.config_for(:settings) }

      it 'loads the right configuration' do
        expected_configuration = {
          credentials: {
            password: 'secret-password',
            username: 'test'
          },
          host: 'localhost',
          port: 8080
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
