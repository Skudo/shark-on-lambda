# frozen_string_literal: true

module SharkOnLambda
  module ApiGateway
    # The `multiValueQueryStringParameters` object from the API Gateway event
    # keeps _all_ values in an array, regardless of the actual size of the array
    # and regardless of the "intent" of the query string parameter.
    #
    # In order to normalise this behaviour, we treat the query strings
    #
    #   `key=value1&key=value2`
    #
    # and
    #
    #   `key[]=value1&key[]=value2`
    #
    # the same. Both are to be serialised to the query string
    #
    #   `key[]=value1&key[]=value2`
    #
    # However, the query strings
    #
    #   `key=value`
    #
    # and
    #
    #   `key[]=value`
    #
    # are _not_ to be treated the same.
    class Query
      def initialize
        @params = HashWithIndifferentAccess.new
      end

      def add(key, values)
        if key.to_s.end_with?('[]')
          actual_key = key[0..-3]
          add_list(actual_key, values)
        else
          values.each { |value| add_item(key, value) }
        end
      end

      def to_h
        @params
      end

      def to_s
        Rack::Utils.build_nested_query(to_h)
      end

      private

      def add_item(key, value)
        if @params[key].nil?
          @params[key] = value
        else
          @params[key] = Array(@params[key])
          @params[key] << value
        end
      end

      def add_list(key, value)
        @params[key] ||= []
        @params[key].concat(value)
      end
    end
  end
end
