# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shark_on_lambda/version'

Gem::Specification.new do |spec|
  spec.name          = 'shark-on-lambda'
  spec.version       = SharkOnLambda::VERSION
  spec.authors       = ['Huy Dinh']
  spec.email         = ['mail@huydinh.eu']

  spec.summary       = 'Deploy your Ruby application to AWS Lambda'
  spec.description   = 'Version 0.0.0 is a dummy gem without any functionality!'
  spec.homepage      = 'https://gitlab.com/skudo/shark-on-lambda'
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

  spec.add_dependency 'bima-doorkeeper-rails', '~> 3.2'
  spec.add_dependency 'bima-http', '~> 2.0'
  spec.add_dependency 'jsonapi-rb'
  spec.add_dependency 'rack'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
