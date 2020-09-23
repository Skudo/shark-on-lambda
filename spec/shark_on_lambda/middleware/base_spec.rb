# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::Base do
  let(:env) { {} }
  let(:instance) { described_class.new }

  describe '#call' do
    subject { instance.call(env) }

    it 'raises NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
