# shark-on-lambda
[![GitHub Actions Test Status](https://github.com/Skudo/shark-on-lambda/workflows/Tests/badge.svg?branch=develop)](https://github.com/Skudo/shark-on-lambda/actions)
[![CodeClimate Maintainability Score](https://api.codeclimate.com/v1/badges/fb0c16b3c6212f97b753/maintainability)](https://codeclimate.com/github/Skudo/shark-on-lambda/maintainability)

`shark-on-lambda` provides a lightweight framework to write Ruby on AWS Lambda
whilst using a familiar approach to web services known from e. g. Ruby on Rails.

## History

For a long time, "going serverless" on AWS Lambda was a world Ruby developers 
only could explore using methods such as packing their own Ruby binaries,
going the JRuby way, running on the Java VM, or using Ruby On Jets.

When AWS went public with the Ruby 2.5 runtime for AWS Lambda at the end of 
2018, that changed for Ruby developers and suddenly, a whole new world opened.

Since it is possible to run any Rack-based application on AWS Lambda, you can
even run your own Rails application there, if you want to.

However, if you prefer a more lightweight solution, `shark-on-lambda` may be
of interest to you, as it offers you a similar approach to things whilst
maintaining a smaller memory footprint.

## Changelog

Have a look at the [actual changelog](changelog.md).

## Installation

Add this line to your application's `gems.rb`:

```ruby
gem 'shark-on-lambda'
```

And then execute:

    $ bundle

Or install it yourself:

    $ gem install shark-on-lambda

## Handlers

Handlers are the entry points for Lambda function invocation, e. g. when they
are triggered by HTTP requests on the API Gateway. They also are responsible for
responding with a well-formed response to the caller.

```ruby
class MyHandler < SharkOnLambda::ApiGatewayHandler
end
```

By inheriting from `SharkOnLambda::ApiGatewayHandler`, your own handler
class is indirectly tied to your controller class by convention: It assumes 
the controller name is `MyController` and it will dispatch events to that
controller.

If you however bring your own class with a different name, you can configure
your handler to use that controller instead:

```ruby
class MyHandler < SharkOnLambda::BaseHandler
  self.controller_class = AnotherController
end
```

All controller methods are going to be automagically mapped to class methods
on the handler class. 

```ruby
class MyController < SharkOnLambda::BaseController
  def index
  end
  
  def show
  end
end

class MyHandler < SharkOnLambda::ApiGatewayHandler
end
```

`MyHandler` will respond to `.index` and `.show` class methods that accept the
`event` and `context` objects from the API Gateway. Those are passed to 
`MyController` and eventually, the controller method that corresponds to the
handler class method is called.

## Controllers

Controllers are similar to Rails controllers: You have access to `params`, 
`request`, and `response` objects that contain informatoni retrieved from the
AWS Lambda `event` object.

### "Basic" controllers

You also have access to the `render` and `redirect_to`.

```ruby
class MyController < SharkOnLambda::BaseController
  def index
    # Make the API Gateway respond with a 201 response saying "Hello, World!"
    # in the response body.
    #
    # The default status code for `render` is 200.    
    render 'Hello, World!', status: 201
  end
  
  def show
    # Does what you think it does.
    #
    # The default status code for `redirect_to` is 302.    
    redirect_to 'https://github.com', status: 307
  end
end
```

`before_action`, `around_action`, and `after_action` filters also are available,
as well as `rescue_from`.

### _JSON API_-compliant controllers

If you inherit your controller from `SharkOnLambda::JsonapiController`, 
`render` and `redirect_to` will create _JSON API_-compliant responses.

You however __must__ have a serialiser for the objects you want to render.
Otherwise, rendering will fail and you will receive an _Internal Server Error_
instead.

_JSON API_ `fields` and `include` query string parameters are automagically
being parsed and used for rendering automagically by the _JSON API_ renderer.

## _JSON API_ serialisers

We use `jsonapi-serializable` (and `jsonapi-rb` in general) for our
_JSON API_ compatibility. Therefore, we expect the serialisers to be inherited
from `::JSONAPI::Serializable::Resource` (or `::JSONAPI::Serializable::Error`).

```ruby
class SomethingSerializer < JSONAPI::Serializable::Resource
  type :somethings
  
  attributes :foo, :bar, :baz
end
```

### Serialiser lookup

Each object that is to be serialised requires a serialiser class that knows
how to serialise it. We also implemented a convention over configuration
approach here to determine which serialiser class to use:

1) If the object is an instance of `YourClass` and `YourClassSerializer` is
   defined, `YourClassSerializer` is used as the serialiser class.
   
2) If the object is an instance of `YourClass` and `YourClassSerializer` is
   __not__ defined, check whether 1) applies for any of the ancestors of
   `YourClass`.   

#### Example
 
If `YourClass` has `YourBaseClass`, `Object`, and `BasicObject` as ancestor 
classes, the first existing one of `YourClassSerializer`, 
`YourBaseClassSerializer`, `ObjectSerializer`, and `BasicObjectSerializer` 
(in that order) is used. If none of those exist, serialisation will fail with
an _Internal Server Error_.

## Configuration

You can "initialise" `SharkOnLambda` using its `.initialize!` class method.

`SharkOnLambda.initialize!` yields to a block with the `config` and `secrets`
objects where you can access and add to those two objects.

```ruby
SharkOnLambda.initialize! do |config, secrets|
  # Do things here.
end
```

Calling `SharkOnLambda.initialize!` does these things (in order):

1. Process the block passed to `.initialize!`.
2. Load `config/settings.yml` and `config/settings.local.yml` into the
   `config` object.
3. Load `config/database.yml` and `config/database.local.yml` into
   `config.database`.
4. Load `config/secrets.yml` and `secrets/secrets.local.yml` into the
   `secrets` object.
5. Load all `config/initializers/*.rb` files.

If `SharkOnLambda.config.stage` was set inside the block passed to
`.initialize!`, configurations and secrets for that stage will be merged into
the default set (the `default` node in the YAML files) of configuration and 
secrets, overwriting values where applicable.

## Test helpers

By including `SharkOnLambda::RSpec::Helpers` in your RSpec test suite, you can 
use `delete`, `get`, `patch`, `post`, and `put` methods, which will return
a `Rack::MockResponse` object. You can also access that response object in your
test examples by calling `response`, but only after you've called either of the
aforementioned methods. Otherwise, an exception will be raised.

You can include the test helpers like this in your `spec/spec_helper.rb`.

```ruby
RSpec.configure do |config|
  config.include SharkOnLambda::RSpec::Helpers
end
```

### _JSON API_ helpers

By including `SharkOnLambda::RSpec::JsonapiHelpers`, you gain all the goodies
from `SharkOnLambda::RSpec::Helpers` _and_ access to `jsonapi_data` and
`jsonapi_errors` methods, which contain the `data` and `errors` keys of the
parsed response body respectively. In addition to that, there is
`jsonapi_attributes`, which returns the `attributes` key from `jsonapi_data`.

## _Rack_ compatibility

As `SharkOnLambda.application` is a _Rack_-compatible application, treating it
as such and using existing _Rack_ middleware is straightforward. 

### Using _Rack_ middleware

The middleware stack can be found at `SharkOnLambda.config.middleware`. Adding
middleware to your stack can be either done by calling `#use`:

```ruby
SharkOnLambda.config.middleware.use Your::Middleware
```

You can also just set up your middleware stack during your 
`SharkOnLambda.initialize!` call:

```ruby
SharkOnLambda.initialize! do |config, secrets|
  config.middleware.use Your::Middleware
end
```

## Development

Clone this repository and change away. Then, once you are done, please submit
a pull request at https://github.com/Skudo/shark-on-lambda/pulls.

However, please make sure the tests (`bundle exec rake spec`) and `rubocop`
(`bundle exec rubocop`) pass before submitting a pull request. Pull requests
that do not pass both on the CI system will not be merged. On the same note,
untested code will not be merged, either.
