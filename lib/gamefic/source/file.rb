module Gamefic

  class Source::File < Source::Base
    @@extensions = ['', '.plot.rb', '.plot', '.rb']
    attr_reader :directories
    attr_accessor :main_dir
    def initialize(*directories)
      @directories = directories || []
    end
    def export name
      @directories.each { |directory|
        @@extensions.each { |ext|
          abs_dir = File.absolute_path(directory, main_dir)
          abs_file = abs_dir + '/' + name + ext
          if File.file?(abs_file)
            return Script::File.new(abs_file, abs_dir)
          end
        }
      }
      raise "Script #{name} not found"
    end
  end

end
