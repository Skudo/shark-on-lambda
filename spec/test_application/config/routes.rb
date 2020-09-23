# frozen_string_literal: true

SharkOnLambda.application.routes.draw do
  scope module: 'test_application' do
    get '/api_gateway/shark-error', to: 'api_gateway#shark_error'
    get '/api_gateway/unknown-error', to: 'api_gateway#unknown_error'

    resources :api_gateway, only: %i[create index]
  end
end
