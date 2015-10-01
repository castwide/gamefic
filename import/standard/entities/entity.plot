class Gamefic::Entity
  include Portable
  include Itemizable
  include ParentRoom
  include Attachable

  attr_writer :locale_description
  serialize :locale_description, :portable?, :itemized?, :attached?
  
  def locale_description
    @locale_description ||= ""
  end
end
