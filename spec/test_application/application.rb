# frozen_string_literal: true

require 'shark-on-lambda'
require 'zeitwerk'

app_directory = File.expand_path('app', __dir__)

loader = Zeitwerk::Loader.new
loader.push_dir(app_directory)
paths_to_skip = Dir['*', '**/concerns', base: app_directory]
paths_to_skip.each do |path_to_skip|
  path_to_skip = File.join(app_directory, path_to_skip)
  loader.collapse(path_to_skip) if File.directory?(path_to_skip)
end
loader.setup

module TestApplication
  class Application < SharkOnLambda::Application
    config.root = File.expand_path(__dir__)
  end
end
SharkOnLambda.application.initialize!
