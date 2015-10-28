require 'gamefic';module Gamefic;class Gamefic::Item < Gamefic::Thing
  def pre_initialize
    self.portable = true
  end
end
;end
