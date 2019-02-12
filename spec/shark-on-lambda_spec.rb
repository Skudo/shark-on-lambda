# frozen_string_literal: true

RSpec.describe SharkOnLambda do
  context 'loading "shark-on-lambda" by itself' do
    subject do
      load File.expand_path('../lib/shark-on-lambda.rb', __dir__)
    end

    it 'does not raise an exception' do
      expect { subject }.to_not raise_exception
    end
  end
end
