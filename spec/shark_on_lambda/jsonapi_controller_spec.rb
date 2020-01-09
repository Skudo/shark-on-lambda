# frozen_string_literal: true

RSpec.describe SharkOnLambda::JsonapiController do
  let(:event) { {} }
  let(:context) { {} }

  let(:controller_class) do
    Class.new(SharkOnLambda::JsonapiController) do
      before_action :before_action_method
      after_action :after_action_method

      def after_action_method; end

      def before_action_method; end

      def index; end

      def after_action_method; end

      def before_action_method; end
    end
  end

  subject do
    SharkOnLambda::JsonapiController.new(event: event, context: context)
  end

  it 'is a direct successor to BaseController' do
    subject = SharkOnLambda::JsonapiController
    expectation = [
      subject,
      SharkOnLambda::BaseController
    ]
    expect(subject.ancestors[0..1]).to eq(expectation)
  end

  describe 'calling a class method' do
    context 'without a matching instance method' do
      subject(:response) do
        controller_class.not_existing(event: event, context: context)
      end

      it 'returns a HTTP 500 response' do
        expect(response[:statusCode]).to eq(500)
      end

      it 'returns a JSON object' do
        expect { JSON.parse(response[:body]) }.to_not raise_error
      end

      it 'returns error messages' do
        data = JSON.parse(response[:body])
        expect(data['errors']).to be_present
      end

      it 'returns an error object' do
        data = JSON.parse(response[:body])
        error_object = data['errors']&.first
        expect(error_object).to be_present
        expect(error_object['status']).to eq('500')
        expect(error_object['detail']).to(
          start_with("undefined method `not_existing'")
        )
      end
    end
  end

  describe '#redirect_to' do
    let(:url) { 'https://example.com' }

    it 'sets an "empty" (as empty as JSON API permits "empty") response body' do
      expectation = { data: {} }.to_json
      response = subject.redirect_to(url).to_h
      expect(response[:body]).to eq(expectation)
    end

    it 'responds with a 307 status code by default' do
      response = subject.redirect_to(url).to_h
      expect(response[:statusCode]).to eq(307)
    end

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

        [0, 100, 200, 400, 500].each do |status|
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
end
