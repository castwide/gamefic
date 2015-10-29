module Gamefic::Use
  def self.any_expression
    Use.expression(
      /^(all|everything|every|anything|any|each|things|stuff)( (that|which) (is|are))?$/,
      /^all of$/,
    )
  end
end
