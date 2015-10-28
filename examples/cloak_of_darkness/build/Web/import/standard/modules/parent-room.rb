require 'gamefic';module Gamefic;module Gamefic::ParentRoom
  def room
    p = parent
    while !p.kind_of?(Room) and !p.nil?
      p = p.parent
    end
    p
  end
end
;end
