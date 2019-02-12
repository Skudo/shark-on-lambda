# frozen_string_literal: true

RSpec.describe SharkOnLambda do
  it 'has a valid version number' do
    expect(SharkOnLambda::VERSION).to be_present
    expect(SharkOnLambda::VERSION).to match(/\A\d+\.\d+\.\d+(\.\w*)?\z/)
  end
end
