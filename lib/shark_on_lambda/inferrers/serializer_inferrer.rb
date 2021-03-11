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
        return @object_class unless @object_class.is_a?(String) || @object_class.is_a?(Symbol)

        @object_class.to_s.camelize.constantize
      end

      def serializer_class_names
        return @serializer_class_names if defined?(@serializer_class_names)

        @serializer_class_names =
          object_class.ancestors.reduce([]) do |result, ancestor|
            ancestor_name = ancestor.name
            next result if ancestor_name.blank?

            result << serializer_name_from_model_name(ancestor_name)
          end
      end

      def serializer_name_from_model_name(model_name)
        "#{model_name.underscore}_serializer".camelize
      end
    end
  end
end
