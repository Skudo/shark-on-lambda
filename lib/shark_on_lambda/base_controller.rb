# frozen_string_literal: true

module SharkOnLambda
  class BaseController < ActionController::Metal
    EXCLUDED_MODULES = [
      AbstractController::Translation,
      AbstractController::AssetPaths,

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
    ActionController::API.without_modules(EXCLUDED_MODULES).each do |mod|
      include mod
    end

    ActionController::Renderers.add :jsonapi do |object, options|
      response.set_header('content-type', 'application/vnd.api+json')
      return { data: {} }.to_json if object.nil?

      jsonapi_renderer = JsonapiRenderer.new(object)

      jsonapi_params = params.slice(:fields, :include)
      jsonapi_params.permit!
      jsonapi_params = JsonapiParameters.new(jsonapi_params.to_h)

      render_options = jsonapi_params.to_h.deep_merge(options)
      jsonapi_object = jsonapi_renderer.render(render_options)

      response.status = jsonapi_renderer.status
      jsonapi_object.to_json
    end

    def self.dispatch(*)
      super
    rescue AbstractController::ActionNotFound,
           AbstractController::DoubleRenderError,
           ActionController::ActionControllerError => e
      raise Errors[500], e.message
    end

    def redirect_to(*)
      super

      self.response_body = no_body? ? nil : { data: {} }.to_json
    end

    private

    def no_body?
      response.status.in?(Response::NO_CONTENT_CODES)
    end
  end
end
