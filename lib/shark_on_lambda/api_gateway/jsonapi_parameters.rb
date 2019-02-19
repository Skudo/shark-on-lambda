# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class JsonapiParameters
      def initialize(params = {})
        @class = default_serializer_classes
        @fields = HashWithIndifferentAccess.new
        @include = []

        parse_params(params) if params.present?
      end

      def classes(serializer_classes = {})
        @class = default_serializer_classes.merge(serializer_classes)
      end

      def fields(serialized_fields = {})
        @fields = serialized_fields.with_indifferent_access
      end

      def includes(*includes_list)
        @include = includes_list
      end

      def to_h
        {
          class: @class,
          fields: @fields,
          include: @include
        }
      end
      alias to_hash to_h

      protected

      def default_serializer_classes
        HashWithIndifferentAccess.new do |hash, key|
          serializer_service = Inferrers::SerializerInferrer.new(key)
          serializer_class = serializer_service.serializer_class
          hash[key] = serializer_class
        end
      end

      def parse_fields_params(fields_params)
        return if fields_params.blank?

        serialized_fields = fields_params.transform_values do |attributes|
          attributes.split(',').map(&:strip).map(&:to_sym)
        end
        fields(serialized_fields)
      end

      def parse_include_params(include_params)
        include_params = ::JSONAPI::IncludeDirective.new(include_params)
        include_params = include_params.to_hash
        includes(include_params.with_indifferent_access)
      end

      def parse_params(params)
        parse_fields_params(params[:fields])
        parse_include_params(params[:include])
      end
    end
  end
end
