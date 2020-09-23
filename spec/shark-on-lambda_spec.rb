# frozen_string_literal: true

RSpec.describe SharkOnLambda do
  context 'loading "shark-on-lambda" by itself' do
    subject do
      load File.expand_path('../lib/shark-on-lambda.rb', __dir__)
    end

    before do
      allow(ActiveSupport::Deprecation).to receive(:warn)
    end

    it 'does not raise an exception' do
      expect { subject }.to_not raise_exception
    end

    it 'prints a deprecation warning' do
      subject
      expect(ActiveSupport::Deprecation).to have_received(:warn).once
    end
  end
end
