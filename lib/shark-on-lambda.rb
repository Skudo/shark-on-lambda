# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/deprecation'

deprecation_message = <<-MESSAGE.squish
  Requiring `shark-on-lambda` is deprecated and will be removed in version 3.0. 
  Please require `shark_on_lambda` instead.
MESSAGE
ActiveSupport::Deprecation.warn(deprecation_message, caller(2))

require 'shark_on_lambda'
