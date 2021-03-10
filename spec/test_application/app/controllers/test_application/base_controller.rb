# frozen_string_literal: true

module TestApplication
  class BaseController < SharkOnLambda::BaseController
    before_action :before_action_method
    after_action :after_action_method

    rescue_from HandledException do |e|
      render jsonapi: SharkOnLambda::Errors[400].new(e.message), status: 400
    end

    def invalid_redirect
      redirect_to nil
    end

    def render_nil
      render jsonapi: nil
    end

    def redirect_once
      redirect_to 'https://example.com'
    end

    # def redirect_then_render
    #   redirect_to 'https://example.com'
    #   render plain: 'Hello, world!'
    # end

    def redirect_twice
      redirect_to 'https://example.com'
      redirect_to 'https://example.com'
    end

    def redirect_with_304
      redirect_to 'https://example.com', status: 304
    end

    # def render_then_redirect
    #   render plain: 'Hello, world!'
    #   redirect_to 'https://example.com'
    # end
    #
    # def render_twice
    #   render plain: 'First render'
    #   render plain: 'Second render'
    # end

    def render_unserializable
      render jsonapi: Object.new
    end

    def explode_with_handled_exception
      raise HandledException, 'I was taken care of.'
    end

    def explode_with_unhandled_exception
      raise UnhandledException, 'I was not taken care of.'
    end

    private

    def after_action_method; end

    def before_action_method; end
  end
end
