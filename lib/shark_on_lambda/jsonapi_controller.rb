# frozen_string_literal: true

module SharkOnLambda
  class JsonapiController < BaseController
    ActionController::Renderers.add :jsonapi do |object, options|
      response.set_header('content-type', 'application/vnd.api+json')
      return { data: {} }.to_json if object.nil?

      jsonapi_params = JsonapiParameters.new(params)
      jsonapi_renderer = JsonapiRenderer.new(object)
      render_options = jsonapi_params.to_h.deep_merge(options)

      jsonapi_object = jsonapi_renderer.render(render_options)
      response.status = jsonapi_renderer.status

      jsonapi_object.to_json
    end

    def redirect_to(options = {}, response_status = {})
      super
      return if response_status[:status] == 304

      self.response_body = { data: {} }.to_json
    end

    def render(object, options = {})
      options.merge!(jsonapi: object, content_type: 'application/vnd.api+json')

      super(options)
    end
  end
end
