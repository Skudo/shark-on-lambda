# frozen_string_literal: true

module TestApplication
  class JsonapiController < SharkOnLambda::JsonapiController
    before_action :before_action_method
    after_action :after_action_method

    def index; end

    def invalid_redirect
      redirect_to nil
    end

    def redirect_once
      redirect_to 'https://example.com'
    end

    def redirect_then_render
      redirect_to 'https://example.com'
      render plain: 'Hello, world!'
    end

    def redirect_twice
      redirect_to 'https://example.com'
      redirect_to 'https://example.com'
    end

    def redirect_with_304
      redirect_to 'https://example.com', status: 304
    end

    def render_nil
      render nil
    end

    def render_then_redirect
      render plain: 'Hello, world!'
      redirect_to 'https://example.com'
    end

    def render_twice
      render plain: 'First render'
      render plain: 'Second render'
    end

    def render_unserializable
      render Object.new
    end

    private

    def after_action_method; end

    def before_action_method; end
  end
end
