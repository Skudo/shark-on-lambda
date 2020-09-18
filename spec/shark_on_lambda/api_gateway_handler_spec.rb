# frozen_string_literal: true

RSpec.describe TestApplication::ApiGatewayHandler do
  let!(:context) { build(:api_gateway_context) }
  let!(:event) do
    build(:api_gateway_event, httpMethod: 'GET', path: '/api_gateway')
  end

  let!(:app) { SharkOnLambda.application }

  describe '.call' do
    subject(:response) do
      described_class.call(event: event, context: context, app: app)
    end

    it 'calls the application' do
      allow(app).to receive(:call).and_call_original
      subject
      expect(app).to have_received(:call)
    end

    it 'responds with an API Gateway compatible response' do
      expect(response).to be_a(Hash)
      expect(response.keys).to include('statusCode', 'headers', 'body')
    end
  end
end
