module Gamefic

  class Source::Proc < Source::Text
    def export path
      if @scripts.has_key?(path)
        Script::Proc.new(path, @scripts[path])
      else
        raise "Script #{path} not found"
      end
    end
  end

end
