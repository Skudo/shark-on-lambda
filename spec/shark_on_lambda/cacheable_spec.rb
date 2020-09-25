# frozen_string_literal: true

RSpec.describe SharkOnLambda::Cacheable do
  let(:instance) do
    TestApplication::ClassWithCaching.new
  end

  describe '#cache' do
    subject { instance.cache }

    it 'returns the cache instance' do
      expect(subject).to eq(SharkOnLambda.cache)
    end
  end

  describe '#global_cache' do
    subject { instance.global_cache }

    it 'returns the cache instance' do
      expect(subject).to eq(SharkOnLambda.global_cache)
    end
  end

  describe '#cache_duration' do
    subject { instance.cache_duration(item) }

    context 'with a cache duration set' do
      let(:item) { :known_item }

      it 'returns the set cache duration' do
        expect(subject).to eq(1.minute)
      end
    end

    context 'without a cache duration set' do
      let(:item) { :unknown_item }

      it 'returns the configured default cache duration' do
        expect(subject).to eq(3.minutes)
      end
    end
  end
end
