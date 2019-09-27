# frozen_string_literal: true

RSpec.shared_examples 'finds the right serializer' do |params|
  [
    params[:input],
    params[:input].name,
    params[:input].name.to_sym,
    params[:input].name.underscore,
    params[:input].name.underscore.to_sym
  ].each do |input|
    it 'returns its own serializer class' do
      inferrer = SharkOnLambda::Inferrers::SerializerInferrer.new(input)
      expect(inferrer.serializer_class).to eq(params[:expectation])
    end
  end
end

RSpec.describe SharkOnLambda::Inferrers::SerializerInferrer do
  class ClassWithSerializer; end
  class ClassWithSerializerSerializer; end
  class IntermediateClass < ClassWithSerializer; end
  class IntermediateClassSerializer; end
  class InheritedClass < IntermediateClass; end
  class ClassWithoutSerializer; end

  describe '#serializer_class' do
    context 'with a class that has its own serializer class' do
      include_examples 'finds the right serializer',
                       input: ClassWithSerializer,
                       expectation: ClassWithSerializerSerializer
    end

    context 'with a class that has a serializer for one of its ancestors' do
      include_examples 'finds the right serializer',
                       input: InheritedClass,
                       expectation: IntermediateClassSerializer
    end

    context 'with a class that has no serializer' do
      include_examples 'finds the right serializer',
                       input: ClassWithoutSerializer,
                       expectation: nil
    end
  end
end
