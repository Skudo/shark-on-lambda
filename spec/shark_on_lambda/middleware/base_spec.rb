# frozen_string_literal: true

RSpec.describe SharkOnLambda::Middleware::Base do
  let!(:env) { {} }

  subject do
    SharkOnLambda::Middleware::Base.new
  end

  describe '#call' do
    it 'raises NotImplementedError' do
      expect { subject.call(env) }.to raise_error(NotImplementedError)
    end
  end
end
