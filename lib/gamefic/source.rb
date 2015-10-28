module Gamefic

  class Source
    @@extensions = ['', '.plot', '.rb']
    attr_reader :directories
    attr_accessor :main_dir
    def initialize(*args)
      @directories = args || []
    end
    def export name
      @directories.each { |directory|
        @@extensions.each { |ext|
          abs_dir = File.absolute_path(directory, main_dir)
          abs_file = abs_dir + '/' + name + ext
          if File.file?(abs_file)
            return Script.new(abs_file, abs_dir)
          end
        }
      }
      raise "Script #{name} not found"
    end
    def search path
      found = []
      @directories.each { |base|
        absolute = File.absolute_path(base, main_dir)
        if File.directory?(absolute + '/' + path)
          Dir[absolute + '/' + path + '/' + '*'].each { |file|
            name = File.dirname(file[(base.length)..-1]) + '/' + File.basename(file, File.extname(file))
            found.push name
          }
        end
      }
      found
    end
  end
  
end
