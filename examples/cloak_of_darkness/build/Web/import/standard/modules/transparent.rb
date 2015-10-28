require 'gamefic';module Gamefic;module Gamefic::Transparent
  attr_writer :transparent
  def transparent?
    @transparent ||= false
  end
end
;end
