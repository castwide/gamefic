module Hypertext
  def self.link command, text = nil
    "<a rel=\"gamefic\" href=\"#\" data-command=\"#{command}\">#{text || command}</a>"
  end
end

class Entity
  attr_writer :default_command
  def default_command
    @default_command || "examine #{definitely}"
  end
end

class Character
  def suggestions
    @suggestions ||= []
  end
  def suggest command, text = nil
    suggestions.push Hypertext.link(command, text)
  end
end

assert_action :clear_room_mode do |actor, action|
  actor[:looking_at_room] = false
  actor[:checking_inventory] = false
  true
end

respond :look, Query::Room.new(Room) do |actor, room|
  passthru
  actor[:looking_at_room] = true
end

respond :look, Query::Visible.new(Character) do |actor, character|
  passthru
  actor.suggest "talk to #{the character}"
end

respond :look, Query::Visible.new do |actor, thing|
  passthru
  if thing.is? :portable
    if thing.parent == actor
      actor.stream PC.menu "commands", "drop #{the thing}"
    else
      actor.stream PC.menu "commands", "take #{the thing}"    
    end
  end
  objects = thing.children.that_are(:attached)
  actor.stream '<nav class="objects">'
  objects.each { |object|
    actor.stream PC.link "look #{object}", object
  }
  actor.stream '</nav>'
end

respond :look, Query::Visible.new(Container) do |actor, container|
  passthru
  if container.is?(:lockable) and container.is?(:locked)
    actor.stream PC.menu "commands", "unlock #{the container}"
  elsif container.is?(:openable) and container.is?(:closed)
    actor.stream PC.menu "commands", "open #{the container}"
  else
    if container.is?(:openable) and container.is?(:open)
      actor.stream PC.menu "commands", "close #{the container}"
    end
    if container.is?(:open)
      actor.stream '<nav class="objects">'
      objects = container.children.that_are(:itemized)
      objects.each { |object|
        actor.stream PC.link "look #{object}", object
      }
      actor.stream '</nav>'
    end
  end
end

respond :open, Query::Visible.new(Container) do |actor, container|
  passthru
  if container.is? :open
    actor.perform :look, container
  end
end

#respond :look, Query::Visible.new(Device) do |actor, device|
#  passthru
#  if device.is? :on
#    actor.suggest "turn on #{the device}"
#  else
#    actor.suggest "turn off #{the device}"
#  end
#end

respond :inventory do |actor|
  actor[:checking_inventory] = true
  passthru
end

respond :go, Query::Reachable.new(Door, :locked) do |actor, door|
  passthru
  if door.is? :locked
    #actor.stream PC.menu "commands", "unlock #{the door}"
    actor.suggest "unlock #{the door}"
  end
end

finish_action :show_links do |actor|
  next if actor.state_name != :active
  if actor[:looking_at_room] != true
    actor.suggest "look around"
  end
  if actor[:checking_inventory] != true and actor.children.length > 0
    actor.suggest "inventory"
  end
  if actor.suggestions.length > 0
    actor.stream '<nav class="suggestions">'
    actor.stream "Suggestions: "
    actor.stream actor.suggestions.join(' ')
    actor.stream '</nav>'
    actor.suggestions.clear
  end
  entities = Query::Reachable.new.context_from(actor)
  portals = entities.that_are(Portal)
  if portals.length > 0
    actor.stream '<nav class="portals">'
    actor.stream "Exits: "
    portals.each { |portal|
      actor.stream Hypertext.link("go #{portal.direction}", "#{portal.direction}") + " "
    }
    actor.stream '</nav>'
  end
  characters = entities.that_are(Character) - [actor]
  if characters.length > 0
    actor.stream '<nav class="characters">'
    actor.stream "Characters: "
    characters.each { |entity|
      actor.stream Hypertext.link("examine #{the entity}", "#{the entity}") + " "
    }
    actor.stream '</nav>'
  end
  objects = entities.that_are(:itemized) - characters - [actor]
  if objects.length > 0
    actor.stream '<nav class="objects">'
    actor.stream "Objects: "
    objects.each { |entity|
      actor.stream Hypertext.link("examine #{the entity}", "#{the entity}") + " "
    }
    actor.stream '</nav>'
  end
  extras = entities.that_are(:not_itemized) - characters - [actor]
  if extras.length > 0
    actor.stream '<nav class="incidentals">'
    actor.stream "Incidentals: "
    extras.each { |entity|
      actor.stream Hypertext.link("examine #{the entity}", "#{the entity}") + " "
    }
    actor.stream '</nav>'
  end
end
