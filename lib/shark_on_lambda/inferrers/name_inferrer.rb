# frozen_string_literal: true

module SharkOnLambda
  module Inferrers
    # Determines the inferred name for controllers, deserialisers, handlers,
    # models, and serialisers, based on one of those names or a so-called
    # "name *base*".
    class NameInferrer
      class << self
        # Returns a new instance of NameInferrer based on the given controller
        # name.
        #
        # @param class_name [String] The controller name from which to infer
        #                            other class names.
        # @return [NameInferrer] An instance of NameInferrer based on
        #                        *class_name*.
        def from_controller_name(class_name)
          from_name(:controller, class_name)
        end

        # Returns a new instance of NameInferrer based on the given deserialiser
        # name.
        #
        # @param class_name [String] The deserialiser name from which to infer
        #                            other class names.
        # @return [NameInferrer] An instance of NameInferrer based on
        #                        *class_name*.
        def from_deserializer_name(class_name)
          from_name(:deserializer, class_name)
        end

        # Returns a new instance of NameInferrer based on the given handler
        # name.
        #
        # @param class_name [String] The handler name from which to infer
        #                            other class names.
        # @return [NameInferrer] An instance of NameInferrer based on
        #                        *class_name*.
        def from_handler_name(class_name)
          from_name(:handler, class_name)
        end

        # Returns a new instance of NameInferrer based on the given model name.
        #
        # @param class_name [String] The model name from which to infer
        #                            other class names.
        # @return [NameInferrer] An instance of NameInferrer based on
        #                        *class_name*.
        def from_model_name(class_name)
          from_name(:model, class_name)
        end

        # Returns a new instance of NameInferrer based on the given serialiser
        # name.
        #
        # @param class_name [String] The serialiser name from which to infer
        #                            other class names.
        # @return [NameInferrer] An instance of NameInferrer based on
        #                        *class_name*.
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
                 end
          new(base)
        end
      end

      # Returns a new instance of NameInferrer with the given name *base*.
      #
      # @param base [String] The "name base" from which to infer other names.
      def initialize(base)
        @base = base
      end

      # Returns the inferred controller name.
      #
      # @return [String] The inferred controller name.
      def controller
        "#{@base}_controller".camelize
      end

      # Returns the inferred deserialiser name.
      #
      # @return [String] The inferred deserialiser name.
      def deserializer
        "#{@base}_deserializer".camelize
      end

      # Returns the inferred handler name.
      #
      # @return [String] The inferred handler name.
      def handler
        "#{@base}_handler".camelize
      end

      # Returns the inferred model name.
      #
      # @return [String] The inferred model name.
      def model
        @base.camelize
      end

      # Returns the inferred serialiser name.
      #
      # @return [String] The inferred serialiser name.
      def serializer
        "#{@base}_serializer".camelize
      end
    end
  end
end
