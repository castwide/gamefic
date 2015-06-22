module Gamefic

  class Source
    @@extensions = ['', '.plot', '.rb']
    attr_reader :directories
    def initialize(*args)
      @directories = args
    end
    def export name
      @directories.each { |directory|
        @@extensions.each { |ext|
          absolute = directory + '/' + name + ext
          if File.file?(absolute)
            return Script.new(absolute, directory)
          end
        }
      }
      raise "Script #{name} not found"
    end
    def search path
      found = []
      @directories.each { |base|
        if File.directory?(base + '/' + path)
          Dir[base + '/' + path + '/' + '*'].each { |file|
            name = File.dirname(file[(base.length)..-1]) + '/' + File.basename(file, File.extname(file))
            found.push name
          }
        end
      }
      found
    end
  end
  
end
