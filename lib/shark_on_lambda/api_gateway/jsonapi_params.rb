# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    class JsonapiParams
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
        @fields = HashWithIndifferentAccess.new
        @fields.merge!(serialized_fields)
      end

      def includes(*includes_list)
        @include = includes_list
      end

      def merge(other_hash)
        to_h.deep_merge(other_hash)
      end

      def reverse_merge(other_hash)
        other_hash.deep_merge(to_h)
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

      def parse_class_params(class_params)
        return if class_params.blank?

        classes(class_params)
      end

      def parse_fields_params(fields_params)
        return if fields_params.blank?

        serialized_fields = fields_params.transform_values do |attributes|
          attributes.split(',').map(&:strip).map(&:to_sym)
        end
        serialized_fields.transform_keys!(&:to_sym)
        fields(serialized_fields)
      end

      def parse_include_params(include_params)
        return if include_params.blank?

        includes(*parse_include_path(include_params))
      end

      def parse_include_path(include_path)
        return include_path.to_sym if include_path['.'].nil?

        result = HashWithIndifferentAccess.new
        resource_type, remaining_path = include_path.split('.', 2)
        result[resource_type] = [parse_include_path(remaining_path)]
        result
      end

      def parse_params(params)
        parse_fields_params(params[:fields])
        parse_include_params(params[:include])
      end
    end
  end
end
