module RoomModes
  attr_writer :description_mode
  def description_seen
    @description_seen ||= Array.new
  end
  def description_seen=(value)
    if value.kind_of?(Array)
      @description_seen = value
    else
      raise "Character#visited must be an Array"
    end
  end
  def description_mode
    @description_mode ||= "brief"
  end
end

class Character
  include RoomModes
end

respond :go, Query.new(:siblings, Portal) do |actor, portal|
  actor.tell "You go #{portal.name}."
  actor.parent = portal.destination
  if actor.description_mode == "superbrief" or (actor.description_mode == "brief" and actor.description_seen.include?(actor.parent))
    actor.perform "itemize room"
  else
    actor.perform "itemize room full"
  end
  if actor.description_seen.include?(actor.parent) == false
    actor.description_seen.push actor.parent
  end
end

respond :brief do |actor|
  actor.description_mode = "brief"
  actor.tell "You are now in BRIEF mode. Detailed descriptions of rooms will only be displayed the first time you visit them. Other options are SUPERBRIEF and VERBOSE."
end

respond :verbose do |actor|
  actor.description_mode = "verbose"
  actor.tell "You are now in VERBOSE mode. Detailed descriptions will be displayed every time you enter a room. Other options are BRIEF and SUPERBRIEF."
end

respond :superbrief do |actor|
  actor.description_mode = "superbrief"
  actor.tell "You are now in VERBOSE mode. Detailed room descriptions will never be displayed unless you LOOK AROUND. Other options are BRIEF and VERBOSE."
end
