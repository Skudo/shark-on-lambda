# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class JsonapiController < BaseController
      # TODO: Evaluate if deserialisation should happen in here, happen
      #       somewhere else in SharkOnLambda, or if it should be something
      #       the user has to take care of entirely.
      #
      # class << self
      #   attr_writer :deserializer_class
      #
      #   def deserializer_class
      #     return @deserializer_class if defined?(@deserializer_class)
      #
      #     name_inferrer = Inferrers::NameInferrer.from_controller_name(name)
      #     @deserializer_class = name_inferrer.deserializer.safe_constantize
      #   end
      # end
      #
      # def payload
      #   if request.raw_post.blank?
      #     raise Errors[400], "The request body can't be empty."
      #   end
      #
      #   deserialize(request.request_parameters[:data])
      # end

      def redirect_to(url, options = {})
        status = options[:status] || 307
        validate_redirection_url!(url)
        validate_redirection_status!(status)

        uri = URI.parse(url)
        response.set_header('Location', uri.to_s)
        render(nil, status: status)
      end

      def render(object, options = {})
        status = options.delete(:status) || 200
        renderer_options = jsonapi_params.to_h.merge(options)

        body = serialize(object, renderer_options)
        update_response(status: status, body: body)

        respond!
      end

      protected

      # def deserialize(data)
      #   deserializer_class = self.class.deserializer_class
      #   if deserializer_class.nil?
      #     raise Errors[500], 'Could not find a deserializer class.'
      #   end
      #
      #   deserializer = deserializer_class.new(data)
      #   deserializer.to_h
      # end

      def jsonapi_params
        @jsonapi_params ||= JsonapiParameters.new(params)
      end

      def jsonapi_renderer
        @jsonapi_renderer ||= JsonapiRenderer.new
      end

      def serialize(object, options = {})
        return { data: {} }.to_json if object.nil?

        jsonapi_hash = jsonapi_renderer.render(object, options)
        jsonapi_hash.to_json
      end
    end
  end
end
