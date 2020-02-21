# frozen_string_literal: true

module SharkOnLambda
  class JsonapiController < BaseController
    ::ActionController::Renderers.add :jsonapi do |object, options|
      response.set_header('content-type', 'application/vnd.api+json')

      if object.nil?
        { data: {} }.to_json
      else
        jsonapi_params = JsonapiParameters.new(params)
        jsonapi_renderer = JsonapiRenderer.new
        render_options = jsonapi_params.to_h.deep_merge(options)

        jsonapi_renderer.render(object, render_options)
      end
    end

    def redirect_to(options = {}, response_status = {})
      super
      return if response_status[:status] == 304

      self.response_body = { data: {} }.to_json
    end

    def render(object, options = {})
      super options.merge(
        jsonapi: object,
        content_type: 'application/vnd.api+json'
      )
    end
  end
end
