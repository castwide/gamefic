require 'gamefic';module Gamefic;module Gamefic::Darkenable
  attr_writer :dark
  def dark?
    @dark ||= false
  end
end
;end
