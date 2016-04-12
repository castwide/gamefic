module Gamefic

  class Script::File < Script::Base
    attr_reader :absolute, :relative
    def initialize(filename, directory)
      @absolute = filename.gsub(/\/+/, '/')
      @relative = filename[directory.length..-1].gsub(/\/+/, '/')
      @path =  (File.dirname(@relative) + '/' + File.basename(@relative, File.extname(@relative))).gsub(/\/+/, '/')
    end
    def read
      File.read(@absolute)
    end
    def path
      @path
    end
  end

end
