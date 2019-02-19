# frozen_string_literal: true

module SharkOnLambda
  module Inferrers
    class SerializerInferrer
      def initialize(object_class)
        @object_class = object_class
      end

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
        end.compact
      end
    end
  end
end
