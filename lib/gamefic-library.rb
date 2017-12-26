require 'gamefic'

module Gamefic
  module Library
    @@libraries = {}

    # Register a library to make its scripts available to Gamefic projects.
    #
    # @param name [String]
    # @param path [String]
    def self.register name, path
      STDERR.puts "WARNING: Overwriting existing path for '#{name}' in Gamefic::Library" if @@libraries.has_key?(name)
      @@libraries[name.to_s] = path
    end

    # Get a list of all library names that are currently known.
    # In order to be known, the library's path needs to have been registered.
    #
    # @return [Array<String>]
    def self.names
      @@libraries.keys
    end

    # Get the path to a library's scripts.
    # Raise a NameError if the specified library name does not exist.
    #
    # @param name [String]
    # @return [String]
    def self.find name
      return @@libraries[name] if @@libraries.has_key?(name)
      raise NameError.new("Gamefic library not found: #{name}")
    end
  end
end
