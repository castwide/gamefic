require 'gamefic';module Gamefic;module Gamefic::Openable
  attr_writer :open, :openable
  def open?
    @open ||= false
  end
  def closed?
    !open?
  end
end
;end
