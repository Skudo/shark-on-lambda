# frozen_string_literal: true

RSpec.describe SharkOnLambda::BaseController do
  let(:action) { 'index' }
  let(:rack_env) do
    {
      'rack.input' => StringIO.new(''),
      'REQUEST_METHOD' => 'GET'
    }
  end
  let(:request) { SharkOnLambda::Request.new(rack_env) }
  let(:response) { SharkOnLambda::Response.new }

  subject do
    TestApplication::BaseController.dispatch(action, request, response)
  end

  context 'without a matching instance method' do
    let(:action) { 'does-not-exist' }

    it 'raises an error' do
      expect { subject }.to raise_error(SharkOnLambda::Errors[500])
    end
  end

  context 'when an exception is thrown' do
    context 'if `rescue_from` knows about that exception' do
      let(:action) { 'explode_with_handled_exception' }

      it 'does not throw an exception' do
        expect { subject }.to_not raise_error
      end

      it 'is being handled by `rescue_from`' do
        expected_body = {
          errors: [
            {
              status: 400,
              title: 'Bad Request',
              detail: 'I was taken care of.',
              source: {}
            }
          ]
        }.to_json

        subject
        expect(response.response_code).to eq(400)
        expect(response.body).to eq(expected_body)
      end
    end

    context 'if `rescue_from` does not know about that exception' do
      let(:action) { 'explode_with_unhandled_exception' }

      it 'throws an exception' do
        expect { subject }.to raise_error(TestApplication::UnhandledException)
      end
    end
  end

  describe '#redirect_to' do
    let(:action) { 'redirect_once' }
    let(:url) { 'https://example.com' }

    it 'sets an "empty" (as empty as JSON API permits "empty") response body' do
      expectation = { data: {} }.to_json

      subject
      expect(response.body).to eq(expectation)
    end

    it 'responds with a 302 status code by default' do
      subject
      expect(response.response_code).to eq(302)
    end

    context 'if #redirect_to has been called before' do
      let(:action) { 'redirect_twice' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'if #render has been called before' do
      let(:action) { 'render_then_redirect' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with an unparsable redirection URL' do
      let(:action) { 'invalid_redirect' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with no status code, but a parsable URL' do
      let(:action) { 'redirect_once' }

      before { subject }

      it 'returns a 302 response with a body' do
        expect(response.response_code).to eq(302)
        expect(response.body).to be_present
      end

      it 'sets the "location" header' do
        expect(response.get_header('Location')).to eq(url)
      end
    end

    context 'with a 304 status code' do
      let(:action) { 'redirect_with_304' }

      before { subject }

      it 'sets the response status code' do
        expect(response.response_code).to eq(304)
      end

      it 'sets the "location" header' do
        expect(response.get_header('Location')).to eq(url)
      end

      it 'does not set a response body' do
        expect(response.body).to be_blank
      end
    end
  end

  # TODO: Add actual testing for render behaviour.
  describe '#render' do
    context 'if #redirect_to has been called before' do
      let(:action) { 'redirect_then_render' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'if #render has been called before' do
      let(:action) { 'render_twice' }

      it 'sets the response body to the second render result' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with nil' do
      let(:action) { 'render_nil' }

      before { subject }

      it 'sets an "empty" response body' do
        expectation = { data: {} }.to_json

        expect(response.body).to eq(expectation)
      end

      it 'sets the right content-type header' do
        expect(response.get_header('Content-Type')).to(
          eq('application/vnd.api+json; charset=utf-8')
        )
      end
    end

    context 'with an unserialisable object' do
      let(:action) { 'render_unserializable' }

      before { subject }

      it 'sets the response status code to 500' do
        expect(response.status).to eq(500)
      end

      it 'sets the right content-type header' do
        expect(response.get_header('Content-Type')).to(
          eq('application/vnd.api+json; charset=utf-8')
        )
      end

      it 'sets an error body with a helpful message' do
        errors = JSON.parse(response.body)['errors']
        helpful_errors = errors.select do |error|
          error['detail'].include?('Could not find serializer for: ')
        end
        expect(helpful_errors).to_not be_empty
      end
    end
  end
end
