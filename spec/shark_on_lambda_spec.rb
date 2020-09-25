# frozen_string_literal: true

RSpec.describe SharkOnLambda do
  shared_examples 'behaves like a cache' do |accessor: :cache|
    subject { described_class.public_send(accessor) }

    context 'without having set a specific cache' do
      it 'is a NullStore cache' do
        expect(subject).to be_a(ActiveSupport::Cache::NullStore)
      end
    end

    context 'with a specific cache set' do
      let(:cache) { Object.new }

      it 'returns the given cache object' do
        described_class.public_send("#{accessor}=", cache)
        expect(subject).to eq(cache)
      end
    end
  end

  shared_examples 'delegates to .application' do |method:, target: method|
    let(:application) { SharkOnLambda.application }

    it "delegates .#{method} to .application##{target}" do
      expect(SharkOnLambda.public_send(method)).to(
        eq(application.public_send(target))
      )
    end
  end

  shared_examples 'has a setter function' do |method, value: Object.new|
    it "has a setter function #{method}=" do
      SharkOnLambda.public_send("#{method}=", value)
      expect(SharkOnLambda.public_send(method)).to eq(value)
    end
  end

  describe '.application' do
    subject { SharkOnLambda.application }

    it 'returns an instance of SharkOnLambda::Application' do
      expect(subject).to be_a(SharkOnLambda::Application)
    end
  end

  describe '#cache' do
    include_examples 'behaves like a cache', accessor: :cache
  end

  describe '#global_cache' do
    include_examples 'behaves like a cache', accessor: :global_cache
  end

  include_examples 'delegates to .application', method: :configuration,
                                                target: :config
  include_examples 'delegates to .application', method: :initialize!
  include_examples 'delegates to .application', method: :root

  include_examples 'has a setter function', :env
  include_examples 'has a setter function', :logger
end
