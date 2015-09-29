class Gamefic::Character
  include ParentRoom
  include Arrangement
  include Itemizable
  
  serialize :arrangement, :itemized?
  
end
