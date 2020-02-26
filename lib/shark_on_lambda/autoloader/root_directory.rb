# frozen_string_literal: true

module SharkOnLambda
  module Autoloader
    class RootDirectory
      include Concerns::PathnameConversion

      attr_reader :base_dir, :path

      delegate :cleanpath, :to_s, to: :path

      def initialize(path, base_dir:)
        @path = pathname(path)
        @base_dir = pathname(base_dir)

        raise ArgumentError, "`path' must be absolute." if @path.relative?
      end

      def files(pattern = '**/*.rb')
        Dir.glob(pattern, base: path.to_s).map do |file|
          relative_path = File.expand_path(file, path.to_s)
          absolute_path = File.expand_path(relative_path, base_dir.to_s)
          RubyFile.new(absolute_path, root_directory: self)
        end
      end

      def parent_of?(other_path)
        relative_path = path.relative_path_from(other_path)

        !relative_path.to_s.match(%r{\A(\.\./)*\.\.\z}).nil?
      end
    end
  end
end
