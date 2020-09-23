# frozen_string_literal: true

RSpec.shared_context 'with the given middleware in the stack' do
  let(:app) { SharkOnLambda.application }

  subject do
    app.config.middleware.use described_class
    app.call(env)
  end
end
