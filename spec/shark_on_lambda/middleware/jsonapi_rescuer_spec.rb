# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::JsonapiRescuer do
  let!(:env) { {} }

  subject do
    instance = SharkOnLambda::Middleware::JsonapiRescuer.new(app)
    instance.call(env)
  end

  context 'with no exceptions' do
    let!(:app_response) { [200, {}, 'Hello, world!'] }
    let!(:app) { ->(_env) { app_response } }

    it 'does not do anything with the response' do
      expect(subject).to eq(app_response)
    end
  end

  context 'with a SharkOnLambda::Errors exception' do
    let!(:message) { 'Go away!' }
    let!(:exception) { SharkOnLambda::Errors[403].new(message) }
    let!(:app) { ->(_env) { raise exception } }

    it 'returns the right response status' do
      status, = subject
      expect(status).to eq(exception.status)
    end

    it 'returns no headers' do
      _, headers, = subject
      expect(headers).to eq({})
    end

    it 'returns the right response body' do
      expected_body = {
        errors: [
          { status: '403', title: 'Forbidden', detail: message }
        ]
      }
      _, _, body_proxy = subject
      body = ''
      body_proxy.each { |line| body += line }
      expect(body).to eq(expected_body.to_json)
    end

    it 'returns a closable body' do
      _, _, body_proxy = subject

      expect { body_proxy.close }.to_not raise_error
    end
  end

  context 'with a StandardError exception' do
    let!(:message) { 'I have no idea what happened...' }
    let!(:exception) { StandardError.new(message) }
    let!(:app) { ->(_env) { raise exception } }

    it 'returns the right response status' do
      status, = subject
      expect(status).to eq(500)
    end

    it 'returns no headers' do
      _, headers, = subject
      expect(headers).to eq({})
    end

    it 'returns the right response body' do
      expected_body = {
        errors: [
          { status: '500', title: 'Internal Server Error', detail: message }
        ]
      }

      _, _, body_proxy = subject
      body = ''
      body_proxy.each { |line| body += line }
      expect(body).to eq(expected_body.to_json)
    end

    it 'returns a closable body' do
      _, _, body_proxy = subject

      expect { body_proxy.close }.to_not raise_error
    end
  end
end
