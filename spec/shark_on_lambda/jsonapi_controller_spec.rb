# frozen_string_literal: true

RSpec.describe SharkOnLambda::JsonapiController do
  let!(:action) { 'index' }
  let!(:rack_env) do
    {
      'rack.input' => StringIO.new(''),
      'REQUEST_METHOD' => 'GET'
    }
  end
  let!(:request) { SharkOnLambda::Request.new(rack_env) }
  let!(:response) { SharkOnLambda::Response.new }

  let!(:controller_class) do
    Class.new(SharkOnLambda::JsonapiController) do
      before_action :before_action_method
      after_action :after_action_method

      def after_action_method; end

      def before_action_method; end

      def index; end

      def invalid_redirect
        redirect_to nil
      end

      def redirect_once
        redirect_to 'https://example.com'
      end

      def redirect_then_render
        redirect_to 'https://example.com'
        render plain: 'Hello, world!'
      end

      def redirect_twice
        redirect_to 'https://example.com'
        redirect_to 'https://example.com'
      end

      def redirect_with_304
        redirect_to 'https://example.com', status: 304
      end

      def render_nil
        render nil
      end

      def render_then_redirect
        render plain: 'Hello, world!'
        redirect_to 'https://example.com'
      end

      def render_twice
        render plain: 'First render'
        render plain: 'Second render'
      end

      def after_action_method; end

      def before_action_method; end
    end
  end

  it 'is a direct successor to BaseController' do
    subject = SharkOnLambda::JsonapiController
    expectation = [
      subject,
      SharkOnLambda::BaseController
    ]
    expect(subject.ancestors[0..1]).to eq(expectation)
  end

  subject do
    controller_class.dispatch(action, request, response)
  end

  describe '#redirect_to' do
    let!(:action) { 'redirect_once' }
    let!(:url) { 'https://example.com' }

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
      let!(:action) { 'redirect_twice' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'if #render has been called before' do
      let!(:action) { 'render_then_redirect' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with an unparsable redirection URL' do
      let!(:action) { 'invalid_redirect' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with no status code, but a parsable URL' do
      let!(:action) { 'redirect_once' }

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
      let!(:action) { 'redirect_with_304' }

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
      let!(:action) { 'redirect_then_render' }

      it 'raises an Internal Server Error' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'if #render has been called before' do
      let!(:action) { 'render_twice' }

      it 'sets the response body to the second render result' do
        expect { subject }.to raise_error(SharkOnLambda::Errors[500])
      end
    end

    context 'with nil' do
      let!(:action) { 'render_nil' }

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
  end
end
