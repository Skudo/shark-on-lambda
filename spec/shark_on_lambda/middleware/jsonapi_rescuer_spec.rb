# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::JsonapiRescuer do
  include_context 'with the given middleware in the stack'

  let(:controller) { TestApplication::ApiGatewayController }
  let(:env) { build(:rack_env, :get, controller: controller, action: action) }

  context 'with no exceptions' do
    let(:action) { :index }

    it 'does not raise an exception' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with a SharkOnLambda::Errors exception' do
    let(:action) { :shark_error }

    it 'returns the right response status' do
      status, = subject
      expect(status).to eq(403)
    end

    it 'returns no headers' do
      _, headers, = subject
      expect(headers).to eq({})
    end

    it 'returns the right response body' do
      expected_body = {
        errors: [
          { status: '403', title: 'Forbidden', detail: 'You shall not pass!' }
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
    let(:action) { :unknown_error }

    before { allow(SharkOnLambda.logger).to receive(:error) }

    it 'logs the thrown exception and its backtrace' do
      expect(SharkOnLambda.logger).to receive(:error).twice
      subject
    end

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
          {
            status: '500',
            title: 'Internal Server Error',
            detail: 'Something unexpected happened?'
          }
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
