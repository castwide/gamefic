module Gamefic
  module Library
    autoload :Base, 'gamefic-library/base'

    def self.names
      names = []
      Gamefic::Library::Base.subclasses.each do |s|
        names.push s.new.name
      end
      names
    end

    def self.path name
      Gamefic::Library::Base.subclasses.each do |s|
        return s.path if s.name == name
      end
      raise LoadError.new("Gamefic library not found: #{name}")
    end
  end
end
