module Gamefic

  class Requirement
    def initialize plot, name, &proc
      @plot = plot
      @name = name
      @proc = proc
    end
    def test actor
      return @proc.call actor
    end
  end

end
