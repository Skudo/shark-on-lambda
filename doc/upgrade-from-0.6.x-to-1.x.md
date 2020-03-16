# Upgrading from version `0.6.x` to version `1.x`

## Mandatory changes

### `SharkOnLambda::ApiGateway::*` => `SharkOnLambda::*`

The `ApiGateway` module was removed in favour of a shallower hierarchy, because
`shark-on-lambda` only really does lifting work in an HTTP request context.

### `SharkOnLambda::ApiGateway::BaseHandler` => `SharkOnLambda::ApiGatewayHandler`

In an attempt to make the ties to the _API Gateway_ a bit more explicit, the
handler base class now is `SharkOnLambda::ApiGatewayHandler` instead of what
might be expected to be `SharkOnLambda::BaseHandler`.  

### Use `SharkOnLambda::RSpec::JsonapiHelpers` (or `SharkOnLambda::RSpec::Helpers`)

Until now, making a request to your application has involved building your own
_API Gateway_ event object and then passing it to your handler/controller.

If you have been passing the event object to your handlers solely, this change
is optional. If you however have been passing the event object to your 
controllers, upgrading `shark-on-lambda` to `v1.x` makes changing the way your
tests run a necessity, because controller do not know about _API Gateway_ events
anymore and thus cannot handle them properly.

The recommended way to test controllers is to use 
`SharkOnLambda::RSpec::JsonapiHelpers` (or `SharkOnLambda::RSpec::Helpers`) in
your RSpec tests and then use the methods `delete`, `get`, `patch`, `post`, or
`put` to test your controllers like this:

```ruby
RSpec.describe MyController do
  let!(:service_token) { 'my-super-secret-service-token' }
  let!(:headers) do
    {
      'authorization' => "Bearer #{service_token}"
    }
  end    
  let!(:params) do
    {
      id: 1
    }
  end

  subject { get :show, headers: headers, params: params }

  it { expect(subject.status).to eq(200) }
end
```

Using `SharkOnLambda::RSpec::JsonapiHelpers` or `SharkOnLambda::RSpec::Helpers`
also lets you access the `response` object in your test examples. This object
is an instance of `Rack::MockResponse`, which you might be familiar with from
e. g. controller testing in Rails.

You can use these helpers by e. g. setting them up in `spec/spec_helper.rb`:

```ruby
RSpec.configure do |config|
  config.include SharkOnLambda::RSpec::JsonapiHelpers
end
```

## Recommended changes

### Move to a _Rack_-compatible implementation for CORS headers

Until now, the way to add CORS headers prior to sending the response to the 
_API Gateway_ has been to "decorate" the `#call` method in your handler, e. g.
using a module like

```ruby
module CORS
  def call(action, event:, context:)
    response = super
    response[:headers].reverse_merge!(
      'access-control-allow-origin' => '*',
      'access-control-allow-credentials' => 'true'
    )
    response
  end
end
```  

and then including it in your handler:

```ruby
class MyHandler < SharkOnLambda::ApiGateway::BaseHandler
  include CORS
end
```

This _still_ works for the time being, but it is recommended to switch to an
approach based on using _Rack_ middleware, e. g. `rack-cors` or implementing
your own middleware.

### Use `SharkOnLambda::Middleware::JsonapiRescuer` (or `SharkOnLambda::Middleware::Rescuer`)

Until now, `shark-on-lambda` has caught all uncaught exceptions before building
the response object for _API Gateway_, turning those exceptions into sensible
response objects.

This behaviour changes drastically with `v1.0.0`: Exceptions are not being
caught by the main application anymore. Therefore, it is recommended to add
`SharkOnLambda::Middleware::JsonapiRescuer`
(or `SharkOnLambda::Middleware::Rescuer`) to your middleware stack to restore
this kind of behaviour.

```ruby
SharkOnLambda.initialize! do |config, secrets|
  config.middleware.use SharkOnLambda::Middleware::JsonapiRescuer
end
``` 
