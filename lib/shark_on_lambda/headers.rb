# frozen_string_literal: true

module SharkOnLambda
  class Headers
    def initialize
      @headers = {}
    end

    def [](key)
      @headers[normalized_key(key)]
    end

    def []=(key, value)
      @headers[normalized_key(key)] = value.to_s
    end

    def delete(key)
      @headers.delete(normalized_key(key))
    end

    def key?(key)
      @headers.key?(normalized_key(key))
    end

    def to_h
      @headers.dup
    end

    protected

    def normalized_key(key)
      key.to_s.downcase
    end
  end
end
