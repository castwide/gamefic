module Gamefic

  # Script objects encapsulate data about files that have been evaluated
  # via Plot#require.
  #
  class Script
    attr_reader :absolute, :relative, :base, :read
    def initialize(filename, directory)
      @absolute = filename.gsub(/\/+/, '/')
      @relative = filename[directory.length..-1].gsub(/\/+/, '/')
      @base =  (File.dirname(@relative) + '/' + File.basename(@relative, File.extname(@relative))).gsub(/\/+/, '/')
    end
    def read
      File.read(@absolute)
    end
    def==(other)
      base == other.base
    end
  end

end
