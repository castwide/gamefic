require 'gamefic';module Gamefic;class Gamefic::Character
  include ParentRoom
  include Attachable
  include Itemizable
  include AutoTakes
  
  serialize :attached?, :itemized?
  
end
;end
