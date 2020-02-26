# frozen_string_literal: true

RSpec.describe SharkOnLambda::Concerns::PathnameConversion do
  let!(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::Concerns::PathnameConversion
    end
  end
  let!(:instance) { class_with_mixin.new }

  describe '#pathname' do
    subject { instance.pathname(path) }

    context 'with a Pathname object' do
      let!(:path) { Pathname.new('/') }

      it 'returns the same Pathname object' do
        expect(subject).to be(path)
      end
    end

    context 'with a string' do
      let!(:path) { '/' }

      it 'returns a Pathname object' do
        expect(subject).to be_a(Pathname)
      end

      it 'returns an object containing the path' do
        expect(subject.to_s).to eq(path)
      end
    end

    context 'with something unsupported' do
      [[], {}, nil, 42].each do |unsupported_object|
        let!(:path) { unsupported_object }

        it 'raises an ArgumentError exception' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
