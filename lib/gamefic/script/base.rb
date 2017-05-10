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

    # Get the script's path.
    #
    # @return [String]
    def path
      raise "#path must be defined in subclasses"
    end

    # Get the absolute path of the script's original file, or its URL for
    # sources that are not file-based.
    #
    # @return [String]
    def absolute_path
      raise "#absolute_path must be defined in subclasses"
    end

    def block
      nil
    end

    # Script objects are equal if their relative paths are the same. Note that
    # they are still considered equal if their absolute paths are different,
    # or even if they come from different types of sources.
    #
    # @param other[Script::Base]
    # @return [Boolean]
    def==(other)
      path == other.path
    end
  end

end
