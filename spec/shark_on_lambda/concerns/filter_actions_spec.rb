# frozen_string_literal: true

RSpec.describe SharkOnLambda::FilterActions do
  let(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::FilterActions

      def my_method; end

      def foo; end

      def fumoffu; end
    end
  end

  context 'with no actions' do
    subject do
      class_with_mixin
    end

    context '.after_actions' do
      it 'is empty' do
        expect(subject.after_actions).to be_empty
      end
    end

    context '.before_actions' do
      it 'is empty' do
        expect(subject.before_actions).to be_empty
      end
    end
  end

  context 'with one action each' do
    subject do
      class_with_mixin.before_action :inspect
      class_with_mixin.after_action :inspect
      class_with_mixin
    end

    context '.after_actions' do
      it 'has one item' do
        expect(subject.after_actions.length).to eq(1)
      end
    end

    context '.before_actions' do
      it 'is empty' do
        expect(subject.before_actions.length).to eq(1)
      end
    end
  end
end
