# frozen_string_literal: true

RSpec.describe SharkOnLambda::Configuration do
  let(:instance) { described_class.instance }

  describe '#root=' do
    let(:path) { '/foo/bar' }

    before { instance.root = path }

    it 'stores the root path as a Pathname object' do
      expect(instance.root).to be_a(Pathname)
      expect(instance.root.to_s).to eq(path)
    end
  end
end
