class Gamefic::Query::AnyExpression < Gamefic::Query::Expression
  def initialize
    super(
      /^(all|everything|every|anything|any|each|things|stuff)( (that|which) (is|are))?$/,
      /^all of$/,    
    )
  end
end

module Gamefic::Use
  def self.any_expression
    Gamefic::Query::AnyExpression.new
  end
end
