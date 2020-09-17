# frozen_string_literal: true

RSpec.describe TestApplication::ApiGatewayHandler do
  let!(:context) { attributes_for(:api_gateway_context) }
  let!(:event) { attributes_for(:api_gateway_event).deep_stringify_keys }

  let!(:controller_class) { TestApplication::ApiGatewayController }

  context 'when calling a class method that matches a controller action' do
    subject { described_class.index(context: context, event: event) }

    it 'ultimately calls the right controller action' do
      expect_any_instance_of(controller_class).to receive(:index)
      subject
    end

    it 'returns a response that is compatible with API Gateway' do
      expect(subject['statusCode']).to be_present
      expect(subject['headers']).to be_a(Hash)
      expect(subject['body']).to eq('Hello, world!')
    end
  end

  context 'when calling a class method without a matching controller action' do
    subject { described_class.does_not_exist(context: context, event: event) }

    it 'raises a NoMethodError exception' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end

  describe '.controller_action?' do
    subject { described_class.controller_action?(action) }

    context 'with a matching controller action' do
      let!(:action) { 'index' }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'without a matching controller' do
      let!(:action) { 'does_not_exist' }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '.controller_class_name' do
    subject { described_class.controller_class_name }

    it 'returns the inferred controller class name' do
      expect(subject).to eq('TestApplication::ApiGatewayController')
    end
  end

  describe '#call' do
    subject do
      instance = described_class.new
      instance.call(action, event: event, context: context)
    end

    context 'with an action that matches a controller action' do
      let!(:action) { 'index' }

      it 'ultimately calls the right controller action' do
        expect_any_instance_of(controller_class).to receive(:index)
        subject
      end

      it 'returns a response that is compatible with API Gateway' do
        expect(subject['statusCode']).to be_present
        expect(subject['headers']).to be_a(Hash)
        expect(subject['body']).to eq('Hello, world!')
      end
    end

    context 'with an action that does not match a controller action' do
      let!(:action) { 'does_not_exist' }

      it 'raises a NoMethodError exception' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end
end
