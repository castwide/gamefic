module Gamefic::Use
  def self.any_expression
    Use.expression(
      /^(all|everything|every|anything|any|each)( (that|which) (is|are))?$/,
      /^all of$/,
      /^things (that|which) (is|are)$/
    )
  end
end
