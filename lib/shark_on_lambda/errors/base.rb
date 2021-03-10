# frozen_string_literal: true

module SharkOnLambda
  module Errors
    class Base < StandardError
      attr_accessor :id, :code, :meta, :pointer, :parameter
      attr_writer :detail

      def self.status(status_code)
        define_method :status do
          status_code
        end
      end

      def detail
        return @detail if @detail.present?
        return nil if message == self.class.name

        message
      end

      def title
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end

    def self.[](status_code)
      @errors[status_code]
    end

    @errors = Rack::Utils::HTTP_STATUS_CODES.map do |status_code, message|
      next unless (400..599).cover?(status_code) && message.present?

      error_class = Class.new(Base) do
        status status_code
      end
      class_name_parts = message.to_s.split(/\s+/)
      class_name_parts.map! { |word| word.gsub(/[^a-z]/i, '').capitalize }
      class_name = class_name_parts.join
      const_set(class_name, error_class)

      [status_code, error_class]
    end
    @errors.compact!
    @errors = @errors.to_h
  end
end
