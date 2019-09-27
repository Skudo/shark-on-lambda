# frozen_string_literal: true

RSpec.describe SharkOnLambda::Errors::BaseSerializer do
  let(:error_message) { 'To err or not to err, that is the question.' }
  let(:error_attributes) do
    {
      id: '12345678-9012-3456-78901234',
      code: '42',
      meta: {
        count: 12,
        other_attribute: 34
      }
    }
  end
  let(:error_source) do
    {
      pointer: '/some/pointer',
      parameter: 'foo'
    }
  end
  let(:error) do
    error_class = Class.new(SharkOnLambda::Errors::Base) do
      status 415
    end
    error_class.new(error_message).tap do |error|
      error_attributes.each_pair { |key, value| error.send("#{key}=", value) }
      error_source.each_pair { |key, value| error.send("#{key}=", value) }
    end
  end

  context '#as_jsonapi' do
    subject do
      serializer = SharkOnLambda::Errors::BaseSerializer.new(
        object: error
      )
      serializer.as_jsonapi
    end

    it 'returns a correctly serialized (single) error object' do
      expectation = error_attributes.merge(
        status: error.status,
        title: error.title,
        detail: error_message,
        source: error_source
      )
      expect(subject).to eq(expectation)
    end
  end
end
