module Gamefic::Use
  def self.not_expression
    Use.expression(
      /^(all|everything|every|anything|any|each|things|stuff)( (that|which) (is|are))? not$/
    )
  end
end
