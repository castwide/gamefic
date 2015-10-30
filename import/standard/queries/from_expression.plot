class Gamefic::Query::FromExpression < Gamefic::Query::Expression
  def initialize
    super(
      /^(from|in|of|inside|on)$/
    )
  end
  def signature
    "#{self.class}"
  end
end

module Gamefic::Use
  def self.from_expression
    Gamefic::Query::FromExpression.new
  end
end
