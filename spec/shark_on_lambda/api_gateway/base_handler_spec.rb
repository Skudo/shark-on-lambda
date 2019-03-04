# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::BaseHandler do
  let(:event) { attributes_for(:api_gateway_event) }
  let(:context) { build(:api_gateway_context) }
  let(:controller_arguments) do
    {
      event: event,
      context: context
    }
  end
  let(:controller_class) do
    Class.new(SharkOnLambda::ApiGateway::BaseController) do
      def index; end

      def show
        raise StandardError, 'HAHA!'
      end
    end
  end
  let(:controller_instance) { controller_class.new(controller_arguments) }

  subject do
    handler_class = SharkOnLambda::ApiGateway::BaseHandler
    handler_class.controller_class = controller_class
    handler_class
  end

  %i[index show].each do |action|
    context "with an existing controller method ##{action}" do
      describe ".#{action}" do
        it 'calls the controller method' do
          expect_any_instance_of(controller_class).to(
            receive(:call).with(action)
          )
          subject.send(action, event: event, context: context)
        end
      end
    end
  end

  describe '.controller_class' do
    context 'without an explicitly assigned controller class' do
      context 'if the inferred controller class exists' do
        subject do
          Class.new(SharkOnLambda::ApiGateway::BaseHandler) do
            def self.name
              'SharkOnLambda::ApiGateway::BaseHandler'
            end
          end
        end

        it 'returns the inferred controller class' do
          expectation = SharkOnLambda::ApiGateway::BaseController
          expect(subject.controller_class).to eq(expectation)
        end
      end

      context 'if the inferred controller class does not exist' do
        subject do
          Class.new(SharkOnLambda::ApiGateway::BaseHandler) do
            def self.name
              'WeirdHandler'
            end
          end
        end

        it 'returns nil' do
          expect(subject.controller_class).to be_nil
        end
      end
    end

    context 'with an explicitly assigned controller class' do
      it 'returns the controller class' do
        expect(subject.controller_class).to eq(controller_class)
      end
    end
  end

  describe '#call' do
    subject do
      handler_class = SharkOnLambda::ApiGateway::BaseHandler
      handler_class.controller_class = controller_class
      handler_class.new
    end

    it 'initialises a controller with the event and context objects' do
      expect(controller_class).to receive(:new)
        .with(controller_arguments)
        .and_return(controller_instance)

      subject.call(:index, controller_arguments)
    end

    it 'calls the controller method' do
      expect_any_instance_of(controller_class).to receive(:call).with(:index)

      subject.call(:index, controller_arguments)
    end

    context 'without any uncaught errors' do
      it 'returns the return value of the controller call' do
        result = 'Hello, world!'
        allow_any_instance_of(controller_class).to receive(:call)
          .and_return(result)

        expect(subject.call(:index, controller_arguments)).to eq(result)
      end
    end

    context 'with uncaught errors' do
      it 'logs details of the error message' do
        expect(SharkOnLambda.logger).to receive(:error).twice
        subject.call(:show, controller_arguments)
      end

      it 'returns an error response' do
        expectation = {
          statusCode: 500,
          headers: {
            'Content-Type' => 'application/vnd.api+json'
          },
          body: {
            errors: [{
              status: '500',
              title: 'Internal Server Error',
              detail: 'HAHA!'
            }]
          }.to_json
        }

        allow(SharkOnLambda.logger).to receive(:error)

        response = subject.call(:show, controller_arguments)
        %i[statusCode headers body].each do |item|
          expect(response[item]).to eq(expectation[item])
        end
      end
    end
  end
end
