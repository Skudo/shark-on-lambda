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

  let(:controller_class) do
    Class.new(SharkOnLambda::BaseController) do
      before_action :before_action_method
      after_action :after_action_method

      rescue_from HandledException do
        render plain: 'I was taken care of.', status: 400
      end

      def after_action_method; end

      def before_action_method; end

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

      def render_then_redirect
        render plain: 'Hello, world!'
        redirect_to 'https://example.com'
      end

      def render_twice
        render plain: 'First render'
        render plain: 'Second render'
      end

      def explode_with_handled_exception
        raise HandledException, 'I was taken care of.'
      end

      def explode_with_unhandled_exception
        raise UnhandledException, 'I was not taken care of.'
      end

      def after_action_method; end

      def before_action_method; end
    end
  end

  subject do
    controller_class.dispatch(action, request, response)
  end

  before :all do
    class HandledException < StandardError; end
    class UnhandledException < StandardError; end
  end

  after :all do
    Object.send(:remove_const, :HandledException)
    Object.send(:remove_const, :UnhandledException)
  end

  describe '.dispatch' do
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
          subject
          expect(response.response_code).to eq(400)
          expect(response.body).to eq('I was taken care of.')
        end
      end

      context 'if `rescue_from` does not know about that exception' do
        let(:action) { 'explode_with_unhandled_exception' }

        it 'throws an exception' do
          expect { subject }.to(
            raise_error(UnhandledException, 'I was not taken care of.')
          )
        end
      end
    end
  end

  describe '#redirect_to' do
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

      it 'returns a 307 response with a body' do
        subject
        expect(response.response_code).to eq(307)
        expect(response.body).to be_present
      end

      it 'sets the "location" header' do
        subject
        expect(response.get_header('Location')).to eq('https://example.com')
      end
    end

    context 'with a 304 status code' do
      let(:action) { 'redirect_with_304' }

      it 'sets the response status code' do
        subject
        expect(response.response_code).to eq(304)
      end

      it 'sets the "location" header' do
        subject
        expect(response.get_header('Location')).to eq('https://example.com')
      end

      it 'does not set a response body' do
        subject
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
  end
end
