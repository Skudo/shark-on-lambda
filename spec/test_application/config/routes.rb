# frozen_string_literal: true

SharkOnLambda.application.routes.draw do
  get '/api_gateway', to: 'test_application/api_gateway#index'
end
