class Gamefic::Character
  include ParentRoom
  include Attachable
  include Itemizable
  include AutoTakes
  
  serialize :attached?, :itemized?, :auto_takes?
  
end
