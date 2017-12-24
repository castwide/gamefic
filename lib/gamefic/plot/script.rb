module Gamefic
  class Plot
    class Script
      # @return [String]
      attr_reader :path

      # @return [String]
      attr_reader :absolute_path

      def initialize filename, path
        @absolute_path = filename.gsub(/\/+/, '/')
        @path = path
      end

      def read
        File.read(@absolute_path)
      end

      # Script objects are equal if their relative paths are the same. Note that
      # they are still considered equal if their absolute paths are different,
      # or even if they come from different types of sources.
      #
      # @return [Boolean]
      def==(other)
        other.is_a?(Gamefic::Plot::Script) and path == other.path
      end
    end
  end
end
