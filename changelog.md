## Changelog

#### Unreleaesed

- `SharkOnLambda::BaseController` knows `.rescue_from`, `.rescue_with_handler`, and `#rescue_with_handler` from `ActiveSupport::Rescuable`
- Remove the `ApiGateway` namespace, move all items from that namespace up by one level.
- Support `ActiveModel::Errors` nested validation errors.

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
