# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::BaseController do
  let(:event) { attributes_for(:api_gateway_event) }
  let(:context) { build(:api_gateway_context) }

  subject do
    SharkOnLambda::ApiGateway::BaseController.new(event: event,
                                                  context: context)
  end

  describe '#call' do
    let(:controller_class) do
      Class.new(SharkOnLambda::ApiGateway::BaseController) do
        before_action :before_action_method
        after_action :after_action_method

        attr_accessor :called_functions

        %i[after_action_method before_action_method index].each do |method|
          define_singleton_method(method) do
          end
        end
      end
    end

    subject { controller_class.new(event: event, context: context) }

    context 'if the controller method exists' do
      it 'calls the controller method with filter actions' do
        expect(subject).to receive(:before_action_method).once
        expect(subject).to receive(:index).once
        expect(subject).to receive(:after_action_method).once
        subject.call(:index)
      end
    end
  end

  describe '#params' do
    it 'returns a Parameters object' do
      expectation = SharkOnLambda::ApiGateway::Parameters
      expect(subject.params).to be_a(expectation)
    end
  end

  describe '#redirect_to' do
    let(:url) { 'https://example.com' }

    context 'if #redirect_to has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::ApiGateway::Errors[500]

        subject.redirect_to(url)
        expect { subject.redirect_to(url) }.to raise_error(expectation)
      end
    end

    context 'if #render has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::ApiGateway::Errors[500]

        subject.render('')
        expect { subject.redirect_to(url) }.to raise_error(expectation)
      end
    end

    context 'with an unparsable redirection URL' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::ApiGateway::Errors[500]

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
        expectation = SharkOnLambda::ApiGateway::Errors[500]

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

  describe '#render' do
    let(:body) { 'Hello, world!' }

    context 'if #redirect_to has been called before' do
      let(:url) { 'https://example.com' }

      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::ApiGateway::Errors[500]

        subject.redirect_to(url)
        expect { subject.render(body) }.to raise_error(expectation)
      end
    end

    context 'if #render has been called before' do
      it 'raises an Internal Server Error' do
        expectation = SharkOnLambda::ApiGateway::Errors[500]

        subject.render(body)
        expect { subject.render(body) }.to raise_error(expectation)
      end
    end
  end

  describe '#request' do
    it 'returns a Request object' do
      expectation = SharkOnLambda::ApiGateway::Request
      expect(subject.request).to be_a(expectation)
    end
  end

  describe '#response' do
    it 'returns a Response object' do
      expectation = SharkOnLambda::ApiGateway::Response
      expect(subject.response).to be_a(expectation)
    end
  end
end
