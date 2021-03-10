## Changelog

#### Unreleased

#### 2.1.0
- [Fix] `SharkOnLambda::BaseController#render` does not set content type `application/vnd.api+json`
- [Fix] `:jsonapi` Renderer sets content type `application/vnd.api+json` correctly

#### 2.0.0
- [Deprecate] Requiring `shark-on-lambda` is marked as deprecated in favour of requiring `shark_on_lambda`.
- [Break] `SharkOnLambda::Dispatcher` was removed in favour of routing via `ActionDispatch::Routing`.
- [Break] `SharkOnLambda::BaseController` now renders _JSON API_-compliant responses.
- [Break] `SharkOnLambda::JsonapiController` was removed.
- [Break] Support for `path_parameters` in RSpec helpers was removed.
- [Break] Configuration files are not loaded automatically anymore.
- Added `SharkOnLambda::Cacheable`.
- Added `SharkOnLambda.cache` and `SharkOnLambda.global_cache`.
- Added support for routing.
- Use `rack-on-lambda` as an adapter for events from the (REST API flavoured) API Gateway.

#### 1.0.1

- [Fix] `Jsonapi::Renderer#render` should always return a hash.

#### 1.0.0

- [Break] HTTP redirection now uses the status code `302`.
- [Break] Remove the `ApiGateway` namespace, move all items from that namespace up by one level.
- [Break] Remove build rake tasks.
- [Added `SharkOnLambda::LambdaLogger`](https://www.pivotaltracker.com/story/show/169573932)
- Added support for Rack-compatible middleware.
- `SharkOnLambda::BaseController` now acts more like `ActionController::BaseController`.
- Support `ActiveModel::Errors` nested validation errors.
- Added `SharkOnLambda::RSpec::Helpers` and `SharkOnLambda::RSpec::JsonapiHelpers`.
- Moved to GitHub.

#### 0.6.10

- Upgrade `rack` for good measure.

#### 0.6.9

- [Fix] Controllers now execute their parents' `before_actions` and `after_actions`.

#### 0.6.8

- [Fix] `Query` breaks when adding an item with a symbol as a key.
- Set up the GitLab build pipeline.

#### 0.6.7

- [Fix] Build 0.6.6 using the wrong branch.

#### 0.6.6

- [Fix] Handle the quirkiness of API Gateway query strings properly.

#### 0.6.5

- [Fix] Parse nested query string parameters correctly.

#### 0.6.4

- Initial public release.
