# frozen_string_literal: true

RSpec.describe SharkOnLambda::Request do
  let(:path_parameters) do
    {
      'id' => SecureRandom.uuid,
      'parent_id' => SecureRandom.uuid,
      'grandparent_id' => SecureRandom.uuid
    }
  end
  let(:env) do
    {
      'rack.input' => StringIO.new(''),
      'REQUEST_METHOD' => 'GET',
      'shark.path_parameters' => path_parameters
    }
  end

  subject(:instance) { SharkOnLambda::Request.new(env) }

  describe '#path_parameters' do
    it 'contains all path parameters' do
      expect(instance.path_parameters).to eq(path_parameters)
    end
  end
end
