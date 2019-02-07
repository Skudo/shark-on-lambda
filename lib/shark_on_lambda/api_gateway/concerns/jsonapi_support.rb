# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    module JsonapiSupport
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        attr_writer :deserializer_class

        def deserializer_class
          return @deserializer_class if defined?(@deserializer_class)

          name_inferrer = Inferrers::NameInferrer.from_controller_name(name)
          @deserializer_class = name_inferrer.deserializer.safe_constantize
        end
      end

      protected

      def jsonapi_params
        @jsonapi_params ||= JsonapiParams.new(params)
      end

      def jsonapi_renderer
        @jsonapi_renderer ||= JsonapiRenderer.new
      end

      def payload(deserializer: nil)
        return @payload if defined?(@payload)

        if request.raw_post.blank?
          raise Errors[400], "The request body can't be empty."
        end

        data = request.request_parameters[:data]
        deserializer ||= self.class.deserializer_class
        deserializer_object = deserializer.new(data)
        @payload = deserializer_object.to_h
      end

      def render(object, options = {})
        response.status = options.delete(:status) if options[:status]

        headers = options.delete(:headers) || {}
        headers.each { |key, value| response.set_header(key, value) }

        renderer_options = jsonapi_params.merge(options)
        response.body = jsonapi_renderer.render(object, renderer_options)

        respond!
      end
    end
  end
end
