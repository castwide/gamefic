module Gamefic

  class Source::Base
    def initialize
      raise "#initialize must be defined in subclasses"
    end
    def export path
      raise "#export must be defined in subclasses"
    end
  end

end
