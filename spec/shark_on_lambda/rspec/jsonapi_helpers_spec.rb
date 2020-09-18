# frozen_string_literal: true

RSpec.describe SharkOnLambda::RSpec::JsonapiHelpers do
  let!(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::RSpec::JsonapiHelpers

      def self.controller_name
        'TestApplication::FooController'
      end

      def controller_name
        self.class.controller_name
      end
    end
  end

  let!(:action) { 'some_action' }
  let!(:controller_name) { class_with_mixin.controller_name.camelcase }

  let!(:request_headers) do
    {
      'Accept-Encoding': 'br, gzip, deflate'
    }
  end
  let!(:request_params) do
    {
      foo: 'bar',
      baz: 'blubb'
    }
  end

  let!(:response_status) { 200 }
  let!(:response_attributes) do
    {
      name: 'Foo',
      title: 'Bar'
    }.with_indifferent_access
  end
  let!(:response_data) do
    {
      id: SecureRandom.uuid,
      attributes: response_attributes
    }.with_indifferent_access
  end
  let!(:response_body) do
    {
      data: response_data
    }.to_json
  end
  let!(:response_headers) do
    {
      'Content-Length' => response_body.bytesize,
      'Content-Type' => 'application/vnd.api+json'
    }
  end
  let!(:response) { [response_status, response_headers, [response_body]] }

  before do
    allow(SharkOnLambda.application.routes).to(
      receive(:call).and_return(response)
    )
  end

  let!(:instance) { class_with_mixin.new }

  before do
    instance.get action, headers: request_headers, params: request_params
  end

  context 'with a non-error response' do
    describe '#jsonapi_attributes' do
      subject { instance.jsonapi_attributes }

      it { expect(subject).to eq(response_attributes) }
    end

    describe '#jsonapi_data' do
      subject { instance.jsonapi_data }

      it { expect(subject).to eq(response_data) }
    end

    describe '#jsonapi_errors' do
      subject { instance.jsonapi_errors }

      it { expect(subject).to eq([]) }
    end
  end

  context 'with an error response' do
    let!(:response_status) { 401 }
    let!(:response_errors) do
      [
        {
          status: '401',
          title: 'Unauthorized',
          detail: 'You shall not pass!'
        }
      ].map(&:with_indifferent_access)
    end
    let!(:response_body) do
      {
        errors: response_errors
      }.to_json
    end

    describe '#jsonapi_attributes' do
      subject { instance.jsonapi_attributes }

      it { expect(subject).to eq({}) }
    end

    describe '#jsonapi_data' do
      subject { instance.jsonapi_data }

      it { expect(subject).to eq({}) }
    end

    describe '#jsonapi_errors' do
      subject { instance.jsonapi_errors }

      it { expect(subject).to eq(response_errors) }
    end
  end
end
