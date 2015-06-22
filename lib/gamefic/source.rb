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
  end
  
end
