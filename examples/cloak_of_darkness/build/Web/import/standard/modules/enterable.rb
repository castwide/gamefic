require 'gamefic';module Gamefic;module Gamefic::Enterable
  attr_writer :enterable
  def enterable?
    @enterable ||= false
  end
end
;end
