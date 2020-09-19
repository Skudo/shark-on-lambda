# frozen_string_literal: true

RSpec.shared_examples 'does not trigger a Honeybadger notification' do
  subject(:response) { instance.call(env) }

  it 'does not trigger a Honeybadger notification' do
    expect(Honeybadger).to_not receive(:notify)

    if defined?(app_exception)
      expect { response }.to raise_error(app_exception)
    else
      response
    end
  end
end

RSpec.shared_examples 'triggers a Honeybadger notification' do
  subject(:response) { instance.call(env) }

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

RSpec.shared_examples 'raises the exception from the app' do
  subject(:response) { instance.call(env) }

  it 'raises the exception from the app' do
    expect { response }.to raise_error(app_exception)
  end
end

RSpec.describe SharkOnLambda::Middleware::Honeybadger do
  let(:env) do
    {
      'shark.controller' => 'controller',
      'shark.action' => 'action',
      'action_dispatch.request.parameters' => {}
    }
  end
  let(:tags) { 'tags' }
  let(:instance) do
    SharkOnLambda::Middleware::Honeybadger.new(app, tags: tags)
  end

  context 'with no exceptions from the app' do
    let(:app_response) { [200, {}, ['Hello, world!']] }
    let(:app) { ->(_env) { app_response } }

    it 'returns the response from the app' do
      expect(instance.call(env)).to eq(app_response)
    end

    include_examples 'does not trigger a Honeybadger notification'
  end

  context 'with a SharkOnLambda exception from the app' do
    context 'with a client error' do
      let(:app_exception) do
        SharkOnLambda::Errors[404].new('Nothing to see here.')
      end
      let(:app) { ->(_env) { raise app_exception } }

      include_examples 'raises the exception from the app'
      include_examples 'does not trigger a Honeybadger notification'
    end

    context 'with a server error' do
      let(:app_exception) do
        SharkOnLambda::Errors[500].new('Nothing to see here.')
      end
      let(:app) { ->(_env) { raise app_exception } }

      include_examples 'raises the exception from the app'
      include_examples 'triggers a Honeybadger notification'
    end
  end

  context 'with a non-SharkOnLambda exception from the app' do
    let(:app_exception) { RuntimeError.new('Nothing to see here.') }
    let(:app) { ->(_env) { raise app_exception } }

    include_examples 'raises the exception from the app'
    include_examples 'triggers a Honeybadger notification'
  end
end
