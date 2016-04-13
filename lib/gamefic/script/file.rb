module Gamefic

  class Script::File < Script::Base
    attr_reader :path, :absolute_path
    def initialize filename, path
      @absolute_path = filename.gsub(/\/+/, '/')
      @path = path
    end
    def read
      File.read(@absolute_path)
    end
  end

end
