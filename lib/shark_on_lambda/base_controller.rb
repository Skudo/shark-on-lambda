# frozen_string_literal: true

module SharkOnLambda
  class BaseController < ActionController::Metal
    EXCLUDED_MODULES = [
      AbstractController::Translation,
      AbstractController::AssetPaths,

      ActionController::UrlFor,
      ActionController::ConditionalGet,
      ActionController::EtagWithTemplateDigest,
      ActionController::EtagWithFlash,
      ActionController::Caching,
      ActionController::MimeResponds,
      ActionController::ImplicitRender,
      ActionController::Cookies,
      ActionController::Flash,
      ActionController::FormBuilder,
      ActionController::RequestForgeryProtection,
      ActionController::ContentSecurityPolicy,
      ActionController::ForceSSL,
      ActionController::HttpAuthentication::Basic::ControllerMethods,
      ActionController::HttpAuthentication::Digest::ControllerMethods,
      ActionController::HttpAuthentication::Token::ControllerMethods,
      ActionView::Layouts
    ].freeze
    ::ActionController::Base.without_modules(EXCLUDED_MODULES).each do |mod|
      include mod
    end

    def self.dispatch(*)
      super
    rescue ::AbstractController::ActionNotFound,
           ::AbstractController::DoubleRenderError,
           ::ActionController::ActionControllerError => e
      raise Errors[500], e.message
    end

    def redirect_to(*)
      super
      self.response_body = '' if no_body?
    end

    private

    def no_body?
      response.status.in?(Response::NO_CONTENT_CODES)
    end
  end
end
