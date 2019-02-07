# frozen_string_literal: true

module SharkOnLambda
  module Inferrers
    class NameInferrer
      class << self
        def from_controller_name(class_name)
          from_name(:controller, class_name)
        end

        def from_deserializer_name(class_name)
          from_name(:deserializer, class_name)
        end

        def from_handler_name(class_name)
          from_name(:handler, class_name)
        end

        def from_model_name(class_name)
          from_name(:model, class_name)
        end

        def from_serializer_name(class_name)
          from_name(:serializer, class_name)
        end

        protected

        def from_name(type, class_name)
          base = class_name.underscore
          base = case type
                 when :controller, :deserializer, :handler, :serializer
                   base.sub(/_#{type}\z/, '')
                 when :model
                   base
                 else
                   raise ArgumentError, "Can't infer names from type `#{type}'."
                 end
          new(base)
        end
      end

      def initialize(base)
        @base = base
      end

      def controller
        "#{@base}_controller".camelize
      end

      def deserializer
        "#{@base}_deserializer".camelize
      end

      def handler
        "#{@base}_handler".camelize
      end

      def model
        @base.camelize
      end

      def serializer
        "#{@base}_serializer".camelize
      end
    end
  end
end
