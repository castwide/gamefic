class Gamefic::Entity
  include Portable
  include Itemizable
  include ParentRoom
  include Attachable

  attr_writer :locale_description
  
  def locale_description
    @locale_description ||= ""
  end
end
