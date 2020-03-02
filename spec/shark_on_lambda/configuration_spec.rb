# frozen_string_literal: true

RSpec.describe SharkOnLambda::Configuration do
  subject { SharkOnLambda::Configuration }

  it 'is a singleton' do
    expect(subject.ancestors).to include(Singleton)
    expect(subject.instance).to be_a(SharkOnLambda::Configuration)
  end

  describe '#middleware' do
    subject { SharkOnLambda.config.middleware }

    it 'includes SharkOnLambda::Middleware::LambdaLogger by default' do
      expect(subject.middlewares).to(
        include(SharkOnLambda::Middleware::LambdaLogger)
      )
    end
  end

  # TODO: Add tests for SharkOnLambda::Configuration.
end
