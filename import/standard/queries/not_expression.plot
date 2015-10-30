class Gamefic::Query::NotExpression < Gamefic::Query::Expression
  def initialize
    super(
      /^(all|everything|every|anything|any|each|things|stuff)( (that|which) (is|are))? not$/
    )
  end
end

module Gamefic::Use
  def self.not_expression
    Gamefic::Query::NotExpression.new
  end
end
