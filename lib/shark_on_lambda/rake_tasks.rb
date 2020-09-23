# frozen_string_literal: true

require 'action_dispatch/routing/inspector'
require 'rake'
require 'shark_on_lambda'

namespace :'shark-on-lambda' do
  desc 'Print out all defined routes in match order, with names'
  task :routes do
    routes = SharkOnLambda.application.routes.routes
    inspector = ActionDispatch::Routing::RoutesInspector.new(routes)
    formatter = ActionDispatch::Routing::ConsoleFormatter::Sheet.new

    puts inspector.format(formatter)
  end
end
