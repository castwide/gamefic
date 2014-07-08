module Gamefic

  class Requirement
    def initialize plot, name, &proc
      @plot = plot
      @name = name
      @proc = proc
    end
    def test actor, action
      return @proc.call actor, action
    end
  end

end
