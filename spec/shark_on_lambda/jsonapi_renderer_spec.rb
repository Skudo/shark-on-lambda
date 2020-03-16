# frozen_string_literal: true

RSpec.describe SharkOnLambda::JsonapiRenderer do
  shared_examples 'renders a hash' do
    it 'renders a hash' do
      expect(subject).to be_a(Hash)
    end
  end

  class CustomObject
    def id
      SecureRandom.uuid
    end
  end
  class CustomObjectSerializer < JSONAPI::Serializable::Resource; end

  let!(:renderer) { JSONAPI::Serializable::Renderer.new }
  let!(:params) { SharkOnLambda::JsonapiParameters.new.to_h }

  describe '#render' do
    subject do
      instance = SharkOnLambda::JsonapiRenderer.new(
        object,
        renderer: renderer
      )
      instance.render(params)
    end

    context 'with a serializable non-error object' do
      let!(:object) { CustomObject.new }

      include_examples 'renders a hash'

      it 'renders the object using the renderer' do
        expect(renderer).to receive(:render).with(object, params.to_h)
        subject
      end
    end

    context 'with an array of serializable non-error objects' do
      let!(:object) { [CustomObject.new, CustomObject.new] }

      include_examples 'renders a hash'

      it 'renders the array of objects using the renderer' do
        expect(renderer).to receive(:render).with(object, params.to_h)
        subject
      end
    end

    context 'with a serializable error object' do
      let!(:object) { SharkOnLambda::Errors::NotFound.new }

      include_examples 'renders a hash'

      it 'renders the error object using the renderer' do
        expect(renderer).to receive(:render_errors).with([object], params.to_h)
        subject
      end
    end

    context 'with an array of serializable error objects' do
      let!(:object) do
        [
          SharkOnLambda::Errors::NotFound.new,
          SharkOnLambda::Errors::NotFound.new
        ]
      end

      include_examples 'renders a hash'

      it 'renders the array of errors object using the renderer' do
        expect(renderer).to receive(:render_errors).with(object, params.to_h)
        subject
      end
    end

    context 'with an unserializable object' do
      let!(:object) { 'Hello, world!' }

      include_examples 'renders a hash'

      it 'renders an Internal Server Error object' do
        errors = subject[:errors]
        expect(errors.length).to eq(1)
        expect(errors.first[:status]).to eq(500)
      end
    end

    context 'with an array of unserializable objects' do
      let!(:object) do
        [
          'Hello, world!',
          'Nice to meet you!',
          1
        ]
      end

      include_examples 'renders a hash'

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
      let!(:validation_errors) do
        [
          { attribute: :attribute_1, message: 'cannot be empty' },
          { attribute: :attribute_2, message: 'must be empty' },
          { attribute: 'deeply[0].nested[1].attribute', message: 'looks weird' }
        ]
      end
      let!(:object) do
        errors = ActiveModel::Errors.new(CustomObject.new)
        validation_errors.each do |validation_error|
          errors.add(validation_error[:attribute], validation_error[:message])
        end
        errors
      end

      include_examples 'renders a hash'

      it 'renders an array of Unprocessable Entity errors' do
        errors = subject[:errors]
        expect(errors.all? { |error| error[:status] == 422 }).to eq(true)
      end

      it 'renders an array of errors containg validation error messages' do
        expectation = validation_errors.map do |validation_error|
          attribute_name = validation_error[:attribute].to_s.split('.').last
          "`#{attribute_name}' #{validation_error[:message]}"
        end
        errors = subject[:errors]
        expect(errors.map { |error| error[:detail] }).to eq(expectation)
      end

      it 'renders an array of errors containg pointers to the attributes' do
        expectation = validation_errors.map do |validation_error|
          attribute_path = validation_error[:attribute].to_s.tr('.', '/')
          attribute_path = attribute_path.gsub(/\[(\d+)\]/, '/\1')
          "/data/attributes/#{attribute_path}"
        end
        errors = subject[:errors]
        error_pointers = errors.map { |error| error[:source][:pointer] }
        expect(error_pointers).to eq(expectation)
      end
    end
  end
end
