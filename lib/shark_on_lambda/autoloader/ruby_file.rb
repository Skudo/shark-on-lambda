# frozen_string_literal: true

module SharkOnLambda
  module Autoloader
    class RubyFile
      include Concerns::PathnameConversion

      attr_reader :root_directory, :path

      def initialize(path, root_directory:)
        @path = pathname(path)
        @root_directory = root_directory
        @loaded = false
      end

      def autoload!(namespace:)
        return if autoloaded?

        parent = parent_names.reduce(namespace) do |result, parent_name|
          unless result.const_defined?(parent_name, false)
            result.const_set(parent_name, Module.new)
          end

          "#{result.name}::#{parent_name}".constantize
        end

        parent.autoload name, path.to_s
        @loaded = true
      end

      def autoloaded?
        @loaded
      end

      def covered_by_other_root_directory?(root_directories)
        other_root_directories = root_directories - [root_directory]
        other_root_directories.any? do |other_root_directory|
          root_directory.parent_of?(other_root_directory) &&
            other_root_directory.parent_of?(path)
        end
      end

      private

      def name
        name_parts.last
      end

      def name_parts
        relative_path = path.relative_path_from(root_directory)
        parts = relative_path.to_s[0..-4].split('/')
        parts.map!(&:camelize).map(&:to_sym)
      end

      def parent_names
        name_parts[0..-2]
      end
    end
  end
end
