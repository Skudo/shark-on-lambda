# frozen_string_literal: true

module SharkOnLambda
  class JsonapiRenderer
    attr_reader :object, :status

    def initialize(object, renderer: nil)
      @object = object
      @renderer = renderer || JSONAPI::Serializable::Renderer.new

      @status = 200
    end

    def render(options = {})
      @status = options[:status] if options[:status]
      object_to_render = transform_active_model_errors(object)

      unless renderable?(object_to_render, options)
        return handle_unrenderable_objects(object_to_render, options)
      end

      if error?(object_to_render)
        render_errors(object_to_render, options)
      else
        render_success(object_to_render, options)
      end
    end

    protected

    attr_reader :renderer

    def active_model_error?(error)
      return false unless defined?(::ActiveModel::Errors)

      error.is_a?(::ActiveModel::Errors)
    end

    def attribute_name(attribute)
      File.basename(attribute_path(attribute))
    end

    def attribute_path(attribute)
      attribute.to_s.tr('.', '/').gsub(/\[(\d+)\]/, '/\1')
    end

    def error?(object)
      if object.respond_to?(:to_ary)
        object.to_ary.any? { |item| item.is_a?(StandardError) }
      else
        object.is_a?(StandardError)
      end
    end

    def handle_unrenderable_objects(object, options)
      objects_without_serializer = unrenderable_objects(object, options)
      classes_without_serializer = objects_without_serializer.map(&:class)
      classes_without_serializer.uniq!
      errors = classes_without_serializer.map do |item|
        Errors[500].new("Could not find serializer for: #{item.name}.")
      end

      @status = 500
      render_errors(errors, options)
    end

    def render_errors(error, options)
      renderer.render_errors(Array(error), options)
    end

    def render_success(object, options)
      return { data: {} } if object.nil?

      renderer.render(object, options)
    end

    def renderable?(object, options)
      return true if object.nil?

      serializers = serializer_classes(options)

      if object.respond_to?(:to_ary)
        object.to_ary.all? { |item| serializers[item.class.name].present? }
      else
        serializers[object.class.name].present?
      end
    end

    def serializer_classes(options)
      return @serializer_classes if defined?(@serializer_classes)

      @serializer_classes = HashWithIndifferentAccess.new do |hash, key|
        serializer_inferrer = Inferrers::SerializerInferrer.new(key)
        serializer_class = serializer_inferrer.serializer_class
        hash[key] = serializer_class
      end
      @serializer_classes.merge!(options[:class])
    end

    def transform_active_model_errors(errors)
      return errors unless active_model_error?(errors)

      errors.messages.flat_map do |attribute, attribute_errors|
        attribute_errors.map do |attribute_error|
          error_message = "`#{attribute_name(attribute)}' #{attribute_error}"
          Errors[422].new(error_message).tap do |error|
            error.pointer = "/data/attributes/#{attribute_path(attribute)}"
          end
        end
      end
    end

    def unrenderable_objects(object, options)
      if object.respond_to?(:to_ary)
        object.to_ary.reject { |item| renderable?(item, options) }
      else
        renderable?(object, options) ? [] : [object]
      end
    end
  end
end
