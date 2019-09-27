# frozen_string_literal: true

module SharkOnLambda
  class Secrets < OpenStruct
    include Concerns::ResettableSingleton

    class << self
      include Concerns::YamlConfigLoader

      attr_writer :files

      def load(stage, fallback: :default)
        load_secrets(stage, fallback: fallback)

        instance
      end

      def files
        return @files if defined?(@files)

        @files = paths(%w[config/secrets.yml config/secrets.local.yml])
      end

      protected

      def load_secrets(stage, fallback:)
        secrets = load_yaml_files(stage: stage,
                                  fallback: fallback,
                                  paths: files)
        secrets.each_pair { |key, value| instance.send("#{key}=", value) }
      end

      def paths(files)
        files.map { |file| SharkOnLambda.config.root.join(file) }
      end
    end

    def inspect
      # Do not display all the internals of this object when #inspect is called.
      "#<#{self.class.name}>"
    end
  end
end
