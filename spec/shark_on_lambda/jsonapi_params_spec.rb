# frozen_string_literal: true

RSpec.describe SharkOnLambda::JsonapiParameters do
  let(:class_params) { nil }
  let(:fields_params) { nil }
  let(:include_params) { nil }
  let(:params) do
    {
      class: class_params,
      fields: fields_params,
      include: include_params
    }
  end

  subject { SharkOnLambda::JsonapiParameters.new(params) }

  let(:jsonapi_params) { subject.to_h }

  it 'infers the right serializer classes, if they exist' do
    object_class = SharkOnLambda::Errors::Base
    object_class_symbol = object_class.name.to_sym
    serializer_class = SharkOnLambda::Errors::BaseSerializer
    expect(jsonapi_params[:class][object_class_symbol]).to eq(serializer_class)
  end

  describe '.new' do
    context 'without any JSON API parameters' do
      subject { SharkOnLambda::JsonapiParameters.new }

      it 'sets default values' do
        expect(jsonapi_params[:class]).to be_a(HashWithIndifferentAccess)
        expect(jsonapi_params[:class]).to be_empty
        expect(jsonapi_params[:fields]).to be_a(HashWithIndifferentAccess)
        expect(jsonapi_params[:fields]).to be_empty
        expect(jsonapi_params[:include]).to eq([])
      end
    end

    context 'with JSON API parameters' do
      let(:fields_params) do
        {
          object_type_1: 'foo,bar,baz',
          object_type_2: 'foo,bar'
        }
      end
      let(:include_params) { 'foo,foo.bar,foo.baz,foo.bar.baz,bar.baz,baz' }

      it 'processes the :fields parameter correctly' do
        expectation = {
          object_type_1: %i[foo bar baz],
          object_type_2: %i[foo bar]
        }.with_indifferent_access
        expect(jsonapi_params[:fields]).to eq(expectation)
      end

      it 'processes the :include parameter correctly' do
        expectation = [
          bar: {
            baz: {}
          },
          baz: {},
          foo: {
            bar: {
              baz: {}
            },
            baz: {}
          }
        ].map(&:with_indifferent_access)
        expect(jsonapi_params[:include]).to eq(expectation)
      end
    end
  end

  describe '#classes' do
    let(:serializer_class) { SharkOnLambda::Errors::BaseSerializer }
    let(:previously_known_classes) do
      {
        Exception: $stdout
      }.with_indifferent_access
    end
    let(:new_known_classes) do
      {
        StandardError: serializer_class
      }.with_indifferent_access
    end

    it 'sets the explicitly known serializer classes' do
      known_classes = previously_known_classes.merge(new_known_classes)
      subject.classes(known_classes)
      jsonapi_params = subject.to_h

      expect(jsonapi_params[:class]).to eq(known_classes)
    end

    it 'unsets previously known serializer classes' do
      subject.classes(previously_known_classes)
      subject.classes(new_known_classes)
      jsonapi_params = subject.to_h

      expect(jsonapi_params[:class][:StandardError]).to eq(serializer_class)
      expect(jsonapi_params[:class][:Exception]).to be_nil
    end
  end

  describe '#fields' do
    let(:previously_known_fields) do
      {
        foo: %i[bar baz]
      }.with_indifferent_access
    end
    let(:new_known_fields) do
      {
        fumoffu: %i[foo dib foodib]
      }.with_indifferent_access
    end

    it 'sets the list of serialized fields' do
      subject.fields(previously_known_fields)
      subject.fields(new_known_fields)
      jsonapi_params = subject.to_h

      expect(jsonapi_params[:fields]).to eq(new_known_fields)
    end
  end

  describe '#includes' do
    let(:previously_known_includes) do
      [:foo]
    end
    let(:new_known_includes) do
      [
        :foo,
        { fumoffu: %i[foo] }.with_indifferent_access
      ]
    end

    it 'sets the list of included entities' do
      subject.includes(*previously_known_includes)
      subject.includes(*new_known_includes)
      jsonapi_params = subject.to_h

      expect(jsonapi_params[:include]).to eq(new_known_includes)
    end
  end
end
