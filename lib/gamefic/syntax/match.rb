class Gamefic::Syntax::Match
  attr_reader :verb, :arguments
  def initialize verb, arguments
    @verb = verb
    @arguments = arguments
  end
end
