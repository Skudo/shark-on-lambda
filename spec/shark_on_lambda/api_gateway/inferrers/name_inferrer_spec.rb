# frozen_string_literal: true

RSpec.describe SharkOnLambda::Inferrers::NameInferrer do
  class_names = {
    controller: 'MyModule::MyClassController',
    deserializer: 'MyModule::MyClassDeserializer',
    handler: 'MyModule::MyClassHandler',
    model: 'MyModule::MyClass',
    serializer: 'MyModule::MyClassSerializer'
  }
  known_types = class_names.keys

  known_types.each do |source_type|
    describe ".from_#{source_type}_name" do
      subject do
        method_name = "from_#{source_type}_name"
        class_name = class_names[source_type]
        SharkOnLambda::Inferrers::NameInferrer.public_send(method_name,
                                                           class_name)
      end

      known_types.each do |type|
        it "determines the correct #{type} name" do
          expect(subject.public_send(type)).to eq(class_names[type])
        end
      end
    end
  end
end
