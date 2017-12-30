# Scenery is an entity that is not itemized by default. They're typically used
# to provide a description for objects that can be observed but do not respond
# to any other interactions.
#
class Scenery < Thing
  set_default itemized: false
end
