# frozen_string_literal: true

module SharkOnLambda
  class Configuration < OpenStruct
    include Concerns::ResettableSingleton

    attr_writer :stage

    class << self
      include Concerns::YamlConfigLoader

      attr_writer :database_files, :settings_files

      def database_files
        return @database_files if defined?(@database_files)

        files = %w[config/database.yml config/database.local.yml]
        @database_files = paths(files)
      end

      def load(stage, fallback: :default)
        load_settings(stage, fallback: fallback)
        load_database_configuration(stage, fallback: fallback)

        instance
      end

      def settings_files
        return @settings_files if defined?(@settings_files)

        files = %w[config/settings.yml config/settings.local.yml]
        @settings_files = paths(files)
      end

      protected

      def load_database_configuration(stage, fallback:)
        instance.database = load_yaml_files(stage: stage,
                                            fallback: fallback,
                                            paths: paths(database_files))
      end

      def load_settings(stage, fallback:)
        settings = load_yaml_files(stage: stage,
                                   fallback: fallback,
                                   paths: paths(settings_files))
        settings.each_pair do |key, value|
          next if key.to_s == 'serverless'

          instance.send("#{key}=", value)
        end
      end

      def paths(files)
        files.map { |file| SharkOnLambda.config.root.join(file) }
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
