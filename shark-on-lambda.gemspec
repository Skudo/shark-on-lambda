# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shark_on_lambda/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'shark-on-lambda'
  spec.version       = SharkOnLambda::VERSION
  spec.authors       = ['Huy Dinh']
  spec.email         = ['mail@huydinh.eu']

  spec.summary       = 'Write beautiful Ruby applications for AWS Lambda'
  spec.description   = '`shark-on-lambda` does the heavy lifting for writing ' \
                       'web services based on AWS API Gateway on AWS Lambda ' \
                       'using Ruby.'
  spec.homepage      = 'https://github.com/Skudo/shark-on-lambda'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'jsonapi-rb'
  spec.add_dependency 'rack', '>= 2.0.8'
  spec.add_dependency 'zeitwerk', '~> 2.2'

  # TODO: Do we really need `activemodel`?
  #       Or can we get away with mocking out ::ActiveModel::Errors?
  spec.add_development_dependency 'activemodel'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
# rubocop:enable Metrics/BlockLength
