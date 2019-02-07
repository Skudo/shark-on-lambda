# frozen_string_literal: true

module SharkOnLambda
  module YamlConfigLoader
    protected

    def load_yaml_files(stage, *paths)
      result = HashWithIndifferentAccess.new
      paths.each do |path|
        next unless File.exist?(path)

        data = YAML.load_file(path)
        next unless data.is_a?(Hash)

        data = data.with_indifferent_access
        result.merge!(data[stage] || data[:default] || {})
      end
      result
    end
  end
end
