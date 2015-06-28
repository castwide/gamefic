class Rule
  attr_reader :caller
  def initialize name, &block
    @name = name
    @block = block
  end
  def test actor, verb, arguments
    return @block.call actor, verb, arguments
  end
end

class Assert < Rule

end

#class Finish < Rule
#
#end
