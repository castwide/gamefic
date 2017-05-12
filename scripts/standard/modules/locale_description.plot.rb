module LocaleDescription
  attr_writer :locale_description
  
  def locale_description
    @locale_description ||= ""
  end
end
