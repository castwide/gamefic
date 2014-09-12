class Rule
  attr_reader :caller
  def initialize name, &block
    @name = name
    @block = block
  end
  def test actor, action
    return @block.call actor, action
  end
end

class Assert < Rule

end

#class Finish < Rule
#
#end
