# frozen_string_literal: true

FactoryBot.define do
  factory :rack_env, class: Hash do
    as { :json }
    action { nil }
    controller { nil }
    headers { {} }
    params { {} }

    transient do
      http_method { nil }
    end

    SharkOnLambda::RSpec::RequestHelpers::SUPPORTED_HTTP_METHODS.each do |verb|
      trait verb.downcase do
        http_method { verb }
      end
    end

    initialize_with do
      builder = SharkOnLambda::RSpec::EnvBuilder.new(
        action: action,
        controller: controller,
        headers: headers,
        method: http_method,
        params: params,
        as: as
      )
      builder.build
    end
  end
end
