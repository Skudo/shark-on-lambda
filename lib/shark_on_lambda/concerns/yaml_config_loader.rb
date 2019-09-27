# frozen_string_literal: true

module SharkOnLambda
  module Concerns
    # Loads data from YAML files, given a stage and a fallback stage, and
    # merges them in the right order.
    module YamlConfigLoader
      # Loads all files in *paths* in order, returning data from the *stage*
      # and *fallback* stage accordingly.
      #
      # @param stage [String] The stage for which to load data.
      # @param fallback [String] The fallback stage for which to load data,
      #                          if there is no data for *stage*.
      #                          Defaults to: *:default*.
      # @param paths [Array<String>] A list of paths to load data from in order.
      # @return [HashWithIndifferentAccess] A hash with data for *stage* (and
      #                                     *fallback*) from files in *paths*.
      def load_yaml_files(stage:, fallback: :default, paths:)
        result = HashWithIndifferentAccess.new
        paths.each do |path|
          data = load_yaml_file(stage: stage, fallback: fallback, path: path)
          result.deep_merge!(data)
        end
        result
      end

      protected

      # @api private
      def load_yaml_file(stage:, fallback:, path:)
        return HashWithIndifferentAccess.new unless File.exist?(path)

        data = YAML.load_file(path)
        return HashWithIndifferentAccess.new unless data.is_a?(Hash)

        data = data.with_indifferent_access
        data[stage] || data[fallback] || {}
      end
    end
  end
end
