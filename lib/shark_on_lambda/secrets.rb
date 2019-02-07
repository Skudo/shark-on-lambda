# frozen_string_literal: true

module SharkOnLambda
  class Secrets < OpenStruct
    include ResettableSingleton

    class << self
      include YamlConfigLoader

      def load(stage)
        load_secrets(stage)

        instance
      end

      def secrets_files
        %w[config/secrets.yml config/secrets.local.yml].map do |path|
          File.join(SharkOnLambda.config.root, path)
        end
      end

      protected

      def load_secrets(stage)
        secrets = load_yaml_files(stage, *secrets_files)
        secrets.each_pair { |key, value| instance.send("#{key}=", value) }
      end
    end

    def inspect
      # Do not display all the internals of this object when #inspect is called.
      "#<#{self.class.name}>"
    end
  end
end
