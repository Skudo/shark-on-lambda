# frozen_string_literal: true

# frozen_string_literal: true

module SharkOnLambda
  module Autoloader
    class Loader
      include Concerns::PathnameConversion

      attr_reader :root_directories, :base_dir, :namespace

      def initialize(base_dir:, namespace:)
        @base_dir = pathname(base_dir)
        unless @base_dir.absolute?
          raise ArgumentError, "`base_dir' must be an absolute path."
        end

        @namespace = namespace

        @root_directories = []
      end

      def add_root_directories(*patterns)
        patterns.each do |pattern|
          pattern = File.expand_path(pattern, base_dir)
          directories = Dir[pattern].select { |path| File.directory?(path) }
          directories.each { |directory| add_root_directory(directory) }
        end
      end

      def load!
        root_directories.each do |root_directory|
          root_directory.files.each do |file|
            next if file.covered_by_other_root_directory?(root_directories)

            file.autoload!(namespace: namespace)
          end
        end
      end

      private

      def add_root_directory(directory)
        autoload_root = RootDirectory.new(directory, base_dir: base_dir)
        return if @root_directories.include?(autoload_root)

        @root_directories << autoload_root
      end
    end
  end
end
