## Changelog

#### Unreleaesed

- [Break] HTTP redirection now uses the status code `302`.
- [Break] Remove the `ApiGateway` namespace, move all items from that namespace up by one level.
- [Break] Remove build rake tasks.
- [Experimental] Added `SharkOnLambda.autoload`.
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
