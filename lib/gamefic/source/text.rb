module Gamefic

  class Source::Text < Source::Base
    def initialize scripts = {}
      @scripts = scripts
    end
    def export path
      if @scripts.has_key?(path)
        Script::Text.new(path, @scripts[path])
      else
        raise "Script #{path} not found"
      end
    end
  end

end
