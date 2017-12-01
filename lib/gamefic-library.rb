module Gamefic
  module Library
    autoload :Base, 'gamefic-library/base'

    # Get a list of all library names that are currently known.
    # In order to be known, the library's path needs to have been required,
    # e.g., this array will include the 'standard' library if
    # `require 'gamefic-library-standard'` has been executed.
    #
    # @return [Array<String>]
    def self.names
      names = []
      Gamefic::Library::Base.subclasses.each do |s|
        names.push s.new.name
      end
      names
    end

    # Get a library's script path.
    #
    # @return [String]
    def self.path name
      Gamefic::Library::Base.subclasses.each do |s|
        return s.path if s.name == name
      end
      raise LoadError.new("Gamefic library not found: #{name}")
    end
  end
end
