# frozen_string_literal: true

RSpec.describe SharkOnLambda::ApiGateway::DoorkeeperAuthentication do
  let(:class_with_mixin) do
    Class.new do
      include SharkOnLambda::ApiGateway::DoorkeeperAuthentication
    end
  end
  let(:user) { double(::Doorkeeper::User) }

  subject { class_with_mixin.new }

  describe '#authenticate!' do
    context 'with a valid service token' do
      before :each do
        allow(subject).to receive(:service_token_valid?).and_return(true)
        allow(subject).to receive(:service_token_user).and_return(user)
      end

      it 'sets the user' do
        subject.authenticate!
        expect(subject.current_user).to eq(user)
      end
    end

    context 'with an invalid service token' do
      before :each do
        allow(subject).to receive(:service_token_valid?).and_return(false)
        allow(subject).to receive(:service_token_user).and_return(nil)
      end

      it 'raises a Forbidden exception' do
        expectation = SharkOnLambda::ApiGateway::Errors[403]
        expect { subject.authenticate! }.to raise_error(expectation)
      end
    end
  end
end
