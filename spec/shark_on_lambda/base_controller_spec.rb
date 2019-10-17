# frozen_string_literal: true

RSpec.describe SharkOnLambda::BaseController do
  let(:event) { attributes_for(:api_gateway_event) }
  let(:context) { build(:api_gateway_context) }

  subject do
    SharkOnLambda::BaseController.new(event: event, context: context)
  end

  describe '#call' do
    let(:controller_class) do
      Class.new(SharkOnLambda::BaseController) do
        before_action :before_action_method
        after_action :after_action_method

        attr_accessor :called_functions

        rescue_from HandledException do
        end

        %i[after_action_method before_action_method index].each do |method|
          define_singleton_method(method) do
          end
        end

        def explode_with_handled_exception
          raise HandledException
        end

        def explode_with_unhandled_exception
          raise UnhandledException
        end

        def after_action_method; end

        def before_action_method; end
      end
    end

    subject { controller_class.new(event: event, context: context) }

    after do
      Object.send(:remove_const, :HandledException)
      Object.send(:remove_const, :UnhandledException)
    end

    before do
      class HandledException < StandardError; end
      class UnhandledException < StandardError; end
    end

    context 'if the controller method exists' do
      it 'calls the controller method with filter actions' do
        expect(subject).to receive(:before_action_method).once
        expect(subject).to receive(:index).once
        expect(subject).to receive(:after_action_method).once
        subject.call(:index)
      end
    end

    context 'when an exception is thrown' do
      context 'if `rescue_from` knows about that exception' do
        it 'delegates the handling to #rescue_with_handler' do
          expect(subject).to(
            receive(:rescue_with_handler).with(an_instance_of(HandledException))
          ).and_call_original
          subject.call(:explode_with_handled_exception)
        end
      end

      context 'if `rescue_from` does not know about that exception' do
        it 'raises the exception' do
          expect { subject.call(:explode_with_unhandled_exception) }.to(
            raise_error(UnhandledException)
          )
        end
      end
    end
  end

  describe '#params' do
    it 'returns a Parameters object' do
      expectation = SharkOnLambda::Parameters
      expect(subject.params).to be_a(expectation)
    end
  end

  describe '#redirect_to' do
    let(:url) { 'https://example.com' }

    context 'if #redirect_to has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        subject.redirect_to(url)
        expect { subject.redirect_to(url) }.to raise_error(expectation)
      end
    end

    context 'if #render has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        subject.render('')
        expect { subject.redirect_to(url) }.to raise_error(expectation)
      end
    end

    context 'with an unparsable redirection URL' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        [nil, '', '\foo', '"bar"', 'foo bar'].each do |url|
          expect { subject.redirect_to(url) }.to raise_error(expectation)
        end
      end
    end

    context 'with no status code, but a parsable URL' do
      let(:response) do
        response = subject.redirect_to(url)
        response.to_h
      end

      it 'returns a 307 response with a body' do
        expect(response[:statusCode]).to eq(307)
        expect(response[:body]).to be_present
      end

      it 'sets the "location" header' do
        expect(response[:headers]['location']).to eq(url)
      end
    end

    context 'with a non-3xx status code' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        [nil, 0, 100, 200, 400, 500].each do |status|
          expect do
            subject.redirect_to(url, status: status)
          end.to raise_error(expectation)
        end
      end
    end

    http_status_codes = ::Rack::Utils::HTTP_STATUS_CODES.keys
    redirection_status_codes = http_status_codes.select do |status_code|
      (300..399).cover?(status_code)
    end
    redirection_status_codes.each do |status|
      context "with a #{status} status code" do
        let(:response) do
          response = subject.redirect_to(url, status: status)
          response.to_h
        end

        it 'sets the response status code' do
          expect(response[:statusCode]).to eq(status)
        end

        it 'sets the "location" header' do
          expect(response[:headers]['location']).to eq(url)
        end

        if status == 304
          it 'does not set a response body' do
            expect(response[:body]).to be_nil
          end
        else
          it 'sets the response body' do
            expect(response[:body]).to be_present
          end
        end
      end
    end
  end

  # TODO: Add actual testing for render behaviour.
  describe '#render' do
    let(:body) { 'Hello, world!' }

    context 'if #redirect_to has been called before' do
      let(:url) { 'https://example.com' }

      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        subject.redirect_to(url)
        expect { subject.render(body) }.to raise_error(expectation)
      end
    end

    context 'if #render has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::Errors[500]

        subject.render(body)
        expect { subject.render(body) }.to raise_error(expectation)
      end
    end
  end

  describe '#request' do
    it 'returns a Request object' do
      expectation = SharkOnLambda::Request
      expect(subject.request).to be_a(expectation)
    end
  end

  describe '#response' do
    it 'returns a Response object' do
      expectation = SharkOnLambda::Response
      expect(subject.response).to be_a(expectation)
    end
  end
end
