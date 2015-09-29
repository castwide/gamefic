class Gamefic::Entity
  include Portable
  include Itemizable
  include ParentRoom
  include Arrangement
  
  attr_writer :locale_description
  serialize :locale_description, :portable?, :itemized?, :arrangement
  
  def locale_description
    @locale_description ||= ""
  end
end
