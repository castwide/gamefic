class Gamefic::Character
  include ParentRoom
  include Attachable
  include Itemizable
  
  serialize :attached?, :itemized?
  
end
