# frozen_string_literal: true

RSpec.describe SharkOnLambda::Configuration do
  subject { SharkOnLambda::Configuration }

  it 'is a singleton' do
    expect(subject.ancestors).to include(Singleton)
    expect(subject.instance).to be_a(SharkOnLambda::Configuration)
  end

  # TODO: Add tests for SharkOnLambda::Configuration.
end
