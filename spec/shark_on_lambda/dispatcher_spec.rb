# frozen_string_literal: true

RSpec.describe SharkOnLambda::Dispatcher do
  let!(:default_env) do
    {
      'rack.input' => StringIO.new(''),
      'REQUEST_METHOD' => 'GET',
      'shark.controller' => 'test_application/foo_controller',
      'shark.action' => 'index'
    }
  end

  subject do
    SharkOnLambda::Dispatcher.new
  end

  describe '#call' do
    context 'with a non-existent controller' do
      let!(:env) do
        default_env.merge('shark.controller' => 'non_existent')
      end

      it 'raises a NameError exception' do
        expect { subject.call(env) }.to(
          raise_error(NameError, 'uninitialized constant NonExistent')
        )
      end
    end

    context 'with an existing controller' do
      context 'with a non-existent action' do
        let!(:env) do
          default_env.merge('shark.action' => 'non_existent')
        end

        it 'raises an internal server error' do
          expect { subject.call(env) }.to(
            raise_error(SharkOnLambda::Errors[500])
          )
        end
      end

      context 'with an existing action' do
        let!(:env) { default_env }

        it 'returns a rack-compatible response' do
          status, headers, body = subject.call(env)

          expect(status).to be_present
          expect(headers).to be_a(Hash)
          expect(body).to be_present
        end
      end
    end
  end
end
