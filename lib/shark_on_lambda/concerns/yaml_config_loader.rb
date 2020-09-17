# frozen_string_literal: true

module SharkOnLambda
  module Concerns
    module YamlConfigLoader
      def load_yaml_files(paths:, stage:, fallback: :default)
        result = HashWithIndifferentAccess.new
        paths.each do |path|
          data = load_yaml_file(stage: stage, fallback: fallback, path: path)
          result.deep_merge!(data)
        end
        result
      end

      protected

      def load_yaml_file(stage:, fallback:, path:)
        return {} unless File.exist?(path)

        data = YAML.load_file(path)
        return {} unless data.is_a?(Hash)

        data = data.with_indifferent_access
        data[stage] || data[fallback] || {}
      end
    end
  end
end
