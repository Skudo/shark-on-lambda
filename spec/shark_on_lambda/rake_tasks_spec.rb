# frozen_string_literal: true

require 'shark_on_lambda/rake_tasks'

RSpec.describe 'Rake task `shark-on-lambda:routes`' do
  subject(:task) do
    Rake::Task.tasks.find { |task| task.name == 'shark-on-lambda:routes' }
  end

  before do
    Class.new(SharkOnLambda::Application)
    SharkOnLambda.application.routes.draw do
      resources :sharks do
        resources :victims, only: %i[index]
      end
    end
  end

  it 'prints all known routes' do
    expected_output = <<~OUTPUT.chomp
             Prefix Verb   URI Pattern                         Controller#Action
      shark_victims GET    /sharks/:shark_id/victims(.:format) victims#index
             sharks GET    /sharks(.:format)                   sharks#index
                    POST   /sharks(.:format)                   sharks#create
              shark GET    /sharks/:id(.:format)               sharks#show
                    PATCH  /sharks/:id(.:format)               sharks#update
                    PUT    /sharks/:id(.:format)               sharks#update
                    DELETE /sharks/:id(.:format)               sharks#destroy
    OUTPUT

    allow($stdout).to receive(:write)
    task.invoke
    expect($stdout).to have_received(:write).with(expected_output, "\n")
  end
end
