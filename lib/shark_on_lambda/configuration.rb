# frozen_string_literal: true

module SharkOnLambda
  class Configuration < OpenStruct
    include ResettableSingleton

    attr_writer :stage

    class << self
      include YamlConfigLoader

      def database_config_files
        %w[config/database.yml config/database.local.yml].map do |path|
          File.join(instance.root, path)
        end
      end

      def load(stage)
        load_settings(stage)
        load_database_configuration(stage)

        instance
      end

      def settings_files
        %w[config/settings.yml config/settings.local.yml].map do |path|
          File.join(instance.root, path)
        end
      end

      protected

      def load_database_configuration(stage)
        instance.database = load_yaml_files(stage, *database_config_files)
      end

      def load_settings(stage)
        settings = load_yaml_files(stage, *settings_files)
        settings.each_pair do |key, value|
          next if key.to_s == 'serverless'

          instance.send("#{key}=", value)
        end
      end
    end

    def root
      @root ||= Pathname.new('.')
    end

    def root=(new_root)
      @root = Pathname.new(new_root)
    end

    def stage
      @stage || 'development'
    end
  end
end
