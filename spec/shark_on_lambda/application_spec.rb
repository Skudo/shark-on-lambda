# frozen_string_literal: true

RSpec.describe SharkOnLambda::Application do
  let!(:body) do
    Rack::BodyProxy.new(['Hello, world!']) do
    end
  end
  let!(:dispatcher_response) { [200, {}, body] }
  let!(:env) { {} }

  subject do
    SharkOnLambda::Application.new
  end

  before do
    allow(SharkOnLambda.config.dispatcher).to(
      receive(:call).and_return(dispatcher_response)
    )
  end

  describe '#call' do
    context 'without using any middleware' do
      it 'eventually calls the dispatcher' do
        expect(SharkOnLambda.config.dispatcher).to(receive(:call))

        subject.call(env)
      end

      it 'returns a Rack-compatible response' do
        status, headers, body = subject.call(env)

        expect(status).to be_present
        expect(headers).to be_a(Hash)
        expect(body).to be_present
      end

      it 'returns a closable body' do
        _, _, body_proxy = subject.call(env)

        expect { body_proxy.close }.to_not raise_error
      end
    end

    context 'using middleware' do
      before do
        # Doing the obvious
        #
        #     SharkOnLambda.config.middleware.use(
        #       SharkOnLambda::Middleware::Rescuer
        #     )
        #
        # does not work, because it throws an error:
        #
        #     FrozenError: can't modify frozen Array
        #
        stack = ActionDispatch::MiddlewareStack.new
        stack.use(SharkOnLambda::Middleware::Rescuer)
        allow(SharkOnLambda.config).to receive(:middleware).and_return(stack)
      end

      it 'eventually calls the dispatcher' do
        expect(SharkOnLambda.config.dispatcher).to(receive(:call))

        subject.call(env)
      end

      it 'returns a Rack-compatible response' do
        status, headers, body = subject.call(env)

        expect(status).to be_present
        expect(headers).to be_a(Hash)
        expect(body).to be_present
      end

      it 'returns a closable body' do
        _, _, body_proxy = subject.call(env)

        expect { body_proxy.close }.to_not raise_error
      end
    end
  end
end
