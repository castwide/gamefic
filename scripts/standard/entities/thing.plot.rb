class Thing < Gamefic::Entity
  include Portable
  include Itemizable
  include ParentRoom
  include Attachable
  include LocaleDescription
end
