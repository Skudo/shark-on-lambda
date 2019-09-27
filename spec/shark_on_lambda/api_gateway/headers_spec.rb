# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::Headers do
  subject { SharkOnLambda::ApiGateway::Headers.new }

  describe '#[]=' do
    it 'sets the given header (case-insensitive)' do
      subject['FoO'] = 'bar'
      expect(subject.to_h['foo']).to eq('bar')
    end
  end

  describe '#[]' do
    it 'retrieves the given header (case-insensitive)' do
      subject['FoO'] = 'bar'
      expect(subject['fOo']).to eq('bar')
    end
  end

  describe '#delete' do
    it 'deletes the given header (case-insensitive) entirely' do
      subject['foo'] = 'bar'
      subject.delete('foo')
      expect(subject.to_h.key?('foo')).to eq(false)
    end
  end

  describe '#key?' do
    context 'with an existing header (case-insensitive)' do
      it 'returns true' do
        subject['foo'] = 'bar'
        expect(subject.key?('foo')).to eq(true)
      end
    end

    context 'with a non-existing header (case-insensitive)' do
      it 'returns false' do
        expect(subject.key?('baz')).to eq(false)
      end
    end
  end

  describe '#to_h' do
    it 'returns a Hash representation of the headers object' do
      subject['foo'] = 'bar'
      subject['baz'] = 'fumoffu'
      expectation = {
        'foo' => 'bar',
        'baz' => 'fumoffu'
      }
      expect(subject.to_h).to eq(expectation)
    end
  end
end
