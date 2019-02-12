# frozen_string_literal: true

RSpec.describe SharkOnLambda do
  describe '.config' do
    subject { SharkOnLambda.config }

    it 'returns an instance of SharkOnLambda::Configuration' do
      expect(subject).to be_a(SharkOnLambda::Configuration)
    end
  end

  describe '.configure' do
    it 'yields the config and secrets objects' do
      expect do |block|
        SharkOnLambda.configure(&block)
      end.to yield_with_args(SharkOnLambda.config, SharkOnLambda.secrets)
    end
  end

  describe '.secrets' do
    subject { SharkOnLambda.secrets }

    it 'returns an instance of SharkOnLambda::Secrets' do
      expect(subject).to be_a(SharkOnLambda::Secrets)
    end
  end
end
