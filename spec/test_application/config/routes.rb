# frozen_string_literal: true

SharkOnLambda.application.routes.draw do
  get '/api_gateway', to: 'test_application/api_gateway#index'
  match '/api_gateway', via: :all,
                        to: 'test_application/api_gateway#some_action'
  match '/api_gateway', via: :all, to: 'test_application/api_gateway#foo'
end
