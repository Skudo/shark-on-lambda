# frozen_string_literal: true

module SharkOnLambda
  module Inferrers
    # Determines the serialiser class for a given class.
    class SerializerInferrer
      # Returns a new instance of SerializerInferrer with the given
      # *object_class*.
      #
      # @param object_class [Class, String, Symbol] Class to determine the
      #                                             serialiser for.
      def initialize(object_class)
        @object_class = object_class
      end

      # Returns the inferred serialiser class: the serialiser class
      # for exactly *object_class*, for the ancestor closest to *object_class*,
      # or *nil*, whichever comes first.
      #
      # @return [Class] If a serialiser class for *object_class* exists.
      # @return [NilClass] If a serialiser class for *object_class* could not
      #                     be fonud.
      def serializer_class
        return @serializer_class if defined?(@serializer_class)

        serializer_class_names.each do |serializer_class_name|
          @serializer_class = serializer_class_name.safe_constantize
          break if @serializer_class.present?
        end

        @serializer_class
      end

      protected

      def object_class
        unless @object_class.is_a?(String) || @object_class.is_a?(Symbol)
          return @object_class
        end

        @object_class.to_s.camelize.constantize
      end

      def serializer_class_names
        return @serializer_class_names if defined?(@serializer_class_names)

        @serializer_class_names = object_class.ancestors.map do |ancestor|
          ancestor_name = ancestor.name
          next if ancestor_name.blank?

          name_inferrer = NameInferrer.from_model_name(ancestor_name)
          name_inferrer.serializer
        end
        @serializer_class_names.compact! || @serializer_class_names
      end
    end
  end
end
