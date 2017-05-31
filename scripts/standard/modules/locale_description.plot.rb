# Add a locale description to entities.
# In the standard library, itemizing the contents of a room will display an
# entity's locale description instead of adding its name to a list.
#
# Example without locale descriptions:
#   You are in a room.
#   You see a book, a key, and a cup.
#
# Example with a locale description for the cup:
#   You are in a room.
#   You see a book and a key.
#   A gold cup gleams in the candlelight.
#
module LocaleDescription
  attr_writer :locale_description
  
  def locale_description
    @locale_description ||= ''
  end
end
