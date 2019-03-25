# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::Parameters do
  let(:path_parameters) do
    {
      foo: 'foo from path_parameters',
      fumoffu: 'fumoffu from path_parameters'
    }
  end
  let(:query_parameters) do
    {
      foo: 'foo from query_parameters',
      bar: 'bar from query_parameters'
    }
  end
  let(:request_parameters) do
    {
      foo: 'foo from request_parameters',
      bar: 'bar from request_parameters',
      baz: 'baz from request_parameters'
    }
  end
  let(:request) do
    data = {
      path_parameters: path_parameters,
      query_parameters: query_parameters,
      request_parameters: request_parameters
    }
    Struct.new(*data.keys, keyword_init: true).new(data)
  end

  describe '.initialize' do
    subject { SharkOnLambda::ApiGateway::Parameters.new(request) }

    it 'contains all parameters' do
      expectation = request_parameters.deep_dup
      expectation.merge!(query_parameters)
      expectation.merge!(path_parameters)

      expectation.each_pair do |key, value|
        expect(subject[key]).to eq(value)
      end
    end

    it 'merges parameters in the right order' do
      expect(subject[:foo]).to eq('foo from path_parameters')
      expect(subject[:bar]).to eq('bar from query_parameters')
      expect(subject[:baz]).to eq('baz from request_parameters')
      expect(subject[:fumoffu]).to eq('fumoffu from path_parameters')
    end
  end

  describe '#as_json' do
    let(:expectation) do
      expectation = HashWithIndifferentAccess.new
      expectation.merge!(request_parameters)
      expectation.merge!(query_parameters)
      expectation.merge!(path_parameters)
    end

    subject { SharkOnLambda::ApiGateway::Parameters.new(request).as_json }

    it 'returns a hash with all parameters' do
      expect(subject).to eq(expectation)
    end
  end
end
