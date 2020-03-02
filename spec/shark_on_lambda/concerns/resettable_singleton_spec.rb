# frozen_string_literal: true

RSpec.describe SharkOnLambda::Concerns::ResettableSingleton do
  let!(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::Concerns::ResettableSingleton
    end
  end

  subject { class_with_mixin }

  describe '.reset' do
    it '"resets" the singleton object' do
      first_object = subject.instance
      subject.reset
      second_object = subject.instance
      expect(first_object).to_not equal(second_object)
    end
  end

  describe '#instance' do
    it 'returns a singleton object' do
      expect(subject.instance).to be_a(Singleton)
      first_object = subject.instance
      second_object = subject.instance
      expect(first_object).to equal(second_object)
    end
  end
end
