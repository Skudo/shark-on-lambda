# frozen_string_literal: true

module SharkOnLambda
  module Inferrers
    class SerializerInferrer
      def initialize(input)
        @input = input
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

      attr_reader :input

      def object_class
        case input
        when Class then input
        when String, Symbol then input.to_s.camelize.constantize
        else input.class
        end
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
