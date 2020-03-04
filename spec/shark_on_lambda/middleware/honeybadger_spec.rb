# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::Honeybadger do
  let!(:env) do
    {
      'shark.controller' => 'controller',
      'shark.action' => 'action',
      'action_dispatch.request.parameters' => {}
    }
  end
  let!(:tags) { 'tags' }
  let!(:instance) do
    SharkOnLambda::Middleware::Honeybadger.new(app, tags: tags)
  end

  before :all do
    module Honeybadger
      def self.notify(_error, _options = {}); end
    end
  end

  after :all do
    Object.send(:remove_const, :Honeybadger)
  end

  subject(:response) { instance.call(env) }

  context 'with no exceptions from the app' do
    let!(:app_response) { [200, {}, ['Hello, world!']] }
    let!(:app) { ->(_env) { app_response } }

    it 'returns the response from the app' do
      expect(response).to eq(app_response)
    end
  end

  context 'with a SharkOnLambda exception from the app' do
    context 'with a client error' do
      let!(:app_exception) do
        SharkOnLambda::Errors[404].new('Nothing to see here.')
      end
      let!(:app) { ->(_env) { raise app_exception } }

      it 'raises the exception from the app' do
        expect { response }.to raise_error(app_exception)
      end

      it 'does not trigger a Honeybadger notification' do
        expect(Honeybadger).to_not receive(:notify)
        expect { response }.to raise_error(app_exception)
      end
    end

    context 'with a server error' do
      let!(:app_exception) do
        SharkOnLambda::Errors[500].new('Nothing to see here.')
      end
      let!(:app) { ->(_env) { raise app_exception } }

      it 'raises the exception from the app' do
        expect { response }.to raise_error(app_exception)
      end

      it 'triggers a Honeybadger notification' do
        expect(Honeybadger).to receive(:notify).with(app_exception, anything)
        expect { response }.to raise_error(app_exception)
      end

      it 'includes additional information in the Honeybadger notification' do
        expected_options = {
          tags: tags,
          controller: env['shark.controller'],
          action: env['shark.action'],
          parameters: env['action_dispatch.request.parameters']
        }

        expect(Honeybadger).to(
          receive(:notify).with(app_exception, hash_including(expected_options))
        )
        expect { response }.to raise_error(app_exception)
      end
    end
  end

  context 'with a non-SharkOnLambda exception from the app' do
    let!(:app_exception) { RuntimeError.new('Nothing to see here.') }
    let!(:app) { ->(_env) { raise app_exception } }

    it 'raises the exception from the app' do
      expect { response }.to raise_error(app_exception)
    end

    it 'triggers a Honeybadger notification' do
      expect(Honeybadger).to receive(:notify).with(app_exception, anything)
      expect { response }.to raise_error(app_exception)
    end

    it 'includes additional information in the Honeybadger notification' do
      expected_options = {
        tags: tags,
        controller: env['shark.controller'],
        action: env['shark.action'],
        parameters: env['action_dispatch.request.parameters']
      }

      expect(Honeybadger).to(
        receive(:notify).with(app_exception, hash_including(expected_options))
      )
      expect { response }.to raise_error(app_exception)
    end
  end
end
