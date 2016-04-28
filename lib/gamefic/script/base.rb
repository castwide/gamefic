module Gamefic

  class Script::Base
    def initialize
      raise "#initialize must be defined in subclasses"
    end
    # Get the script's text.
    # The text must be source code suitable for evaluation via Plot#stage.
    #
    # @return [String]
    def read
      raise "#read must be defined in subclasses"
    end
    # Get the script's path
    #
    # @return [String]
    def path
      raise "#path must be defined in subclasses"
    end
    # Get the absolute path of the script's original file
    #
    # @return [String]
    def absolute_path
      raise "#absolute_path must be defined in subclasses"
    end
    # @param other[Script::Base]
    # @return [Boolean]
    def==(other)
      path == other.path
    end
  end

end
