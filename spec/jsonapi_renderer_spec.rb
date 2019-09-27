# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::JsonapiRenderer do
  class CustomObject; end
  class CustomObjectSerializer; end

  let(:renderer) { ::JSONAPI::Serializable::Renderer.new }
  let(:params) { SharkOnLambda::ApiGateway::JsonapiParameters.new.to_h }

  describe '#render' do
    subject do
      instance = SharkOnLambda::ApiGateway::JsonapiRenderer.new(
        renderer: renderer
      )
      instance.render(object, params)
    end

    context 'with a serializable non-error object' do
      let(:object) { CustomObject.new }

      it 'renders the object using the renderer' do
        expect(renderer).to receive(:render).with(object, params.to_h)
        subject
      end
    end

    context 'with an array of serializable non-error objects' do
      let(:object) { [CustomObject.new, CustomObject.new] }

      it 'renders the arry of objects using the renderer' do
        expect(renderer).to receive(:render).with(object, params.to_h)
        subject
      end
    end

    context 'with a serializable error object' do
      let(:object) { SharkOnLambda::ApiGateway::Errors::Base.new }

      it 'renders the error object using the renderer' do
        expect(renderer).to receive(:render_errors).with([object], params.to_h)
        subject
      end
    end

    context 'with an array of serializable error objects' do
      let(:object) do
        [
          SharkOnLambda::ApiGateway::Errors::Base.new,
          SharkOnLambda::ApiGateway::Errors::Base.new
        ]
      end

      it 'renders the array of errors object using the renderer' do
        expect(renderer).to receive(:render_errors).with(object, params.to_h)
        subject
      end
    end

    context 'with an unserializable object' do
      let(:object) { 'Hello, world!' }

      it 'renders an Internal Server Error object' do
        errors = subject[:errors]
        expect(errors.length).to eq(1)
        expect(errors.first[:status]).to eq(500)
      end
    end

    context 'with an array of unserializable objects' do
      let(:object) do
        [
          'Hello, world!',
          'Nice to meet you!',
          nil,
          1
        ]
      end

      it 'renders Internal Server Error objects' do
        errors = subject[:errors]
        expect(errors.all? { |error| error[:status] == 500 }).to eq(true)
      end

      it 'renders one Internal Server Error for each unknown serializer' do
        errors = subject[:errors]
        expectation = object.map do |item|
          class_name = item.class.name
          "Could not find serializer for: #{class_name}."
        end
        expectation.uniq!
        expect(errors.map { |error| error[:detail] }).to eq(expectation)
      end
    end

    context 'with an ActiveModel::Errors object (aka "validation errors")' do
      let(:validation_errors) do
        [
          { attribute: 'attribute_1', message: 'cannot be empty' },
          { attribute: 'attribute_2', message: 'must be empty' }
        ]
      end
      let(:object) do
        errors = ::ActiveModel::Errors.new(CustomObject.new)
        validation_errors.each do |validation_error|
          errors.add(validation_error[:attribute], validation_error[:message])
        end
        errors
      end

      it 'renders an array of Unprocessable Entity errors' do
        errors = subject[:errors]
        expect(errors.all? { |error| error[:status] == 422 }).to eq(true)
      end

      it 'renders an array of errors containg validation error messages' do
        expectation = validation_errors.map do |validation_error|
          "`#{validation_error[:attribute]}' #{validation_error[:message]}"
        end
        errors = subject[:errors]
        expect(errors.map { |error| error[:detail] }).to eq(expectation)
      end

      it 'renders an array of errors containg pointers to the attributes' do
        expectation = validation_errors.map do |validation_error|
          "/data/attributes/#{validation_error[:attribute]}"
        end
        errors = subject[:errors]
        error_pointers = errors.map { |error| error[:source][:pointer] }
        expect(error_pointers).to eq(expectation)
      end
    end
  end
end
