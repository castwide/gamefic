module Gamefic
  class Plot
    class Source
      @@extensions = ['.plot.rb', '.plot', '.rb']

      # @return [Array<String>]
      attr_reader :directories

      def initialize(*directories)
        @directories = directories || []
      end

      def export path
        @directories.each { |directory|
          @@extensions.each { |ext|
            abs_file = File.join(directory, path + ext)
            if File.file?(abs_file)
              return Gamefic::Plot::Script.new(abs_file, path)
            end
          }
        }
        raise LoadError.new("cannot load script -- #{path}")
      end
    end
  end
end
