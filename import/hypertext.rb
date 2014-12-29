import 'clothing'

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
  actor.tell "<strong>#{room.name.cap_first}</strong>"
  actor.tell room.description
  with_locales = []
  chars = room.children.that_are(Character) - [actor]
  charsum = []
  chars.each { |char|
    if char.locale_description != ""
      with_locales.push char
    else
      if charsum.length == 0
        charsum.push Hypertext.link char.default_command, char.indefinitely.cap_first
      else
        charsum.push Hypertext.link char.default_command, char.indefinitely
      end
    end
  }
  if charsum.length > 0
    actor.tell "#{charsum.join_and} #{charsum.length == 1 ? 'is' : 'are'} here."
  end
  items = room.children.that_are(:itemized) - [actor] - room.children.that_are(Character)
  itemsum = []
  items.each { |item|
    if item.locale_description != ""
      with_locales.push item
    else
      itemsum.push Hypertext.link item.default_command, item.indefinitely
    end
  }
  if itemsum.length > 0
    actor.tell "You see #{itemsum.join_and}."
  end
  with_locales.each { |entity|
    actor.tell entity.locale_description
  }
  if room.is? :explicit_with_exits
    portals = room.children.that_are(Portal)
    if portals.length > 0
      if portals.length == 1
        actor.tell "There is an exit #{Hypertext.link portals[0].default_command, portals[0].direction}."
      else
        dirs = []
        portals.each { |p|
          dirs.push Hypertext.link p.default_command, p.direction
        }
        actor.tell "There are exits #{dirs.join_and(', ')}."
      end
    end
  end
  if actor.is? :supported
    actor.tell "You are on #{the actor.parent}."
    actor.parent.children.that_are(:supported).that_are_not(actor).each { |s|
      actor.tell "#{Hypertext.link s.default_command, s.indefinitely.cap_first} is on #{the actor.parent}."
    }
  end
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
      actor.suggest "drop #{the thing}"
    else
      actor.suggest "take #{the thing}"    
    end
  end
  objects = thing.children.that_are(:attached)
  actor.stream '<nav class="objects">'
  objects.each { |object|
    actor.tell Hypertext.link "look #{object}", object
  }
  actor.stream '</nav>'
end

respond :look, Query::Visible.new(Container) do |actor, container|
  actor.tell container.description
  container.children.that_are(:attached).that_are(:itemized).each { |item|
    actor.tell "#{An item} is attached to #{the container}."
  }
  if container.is? :openable
    actor.tell "#{The container} is #{container.is?(:open) ? 'open' : 'closed'}."
  end
  if container.is? :open
    contents = container.children.that_are(:contained)
    if contents.length > 0
      array = []
      contents.each { |entity|
        array.push Hypertext.link entity.default_command, entity.indefinitely
      }
      actor.tell "You see #{array.join_and} inside #{the container}."
    end
  end
  if container.is?(:lockable) and container.is?(:locked)
    actor.suggest "unlock #{the container}"
  elsif container.is?(:openable) and container.is?(:closed)
    actor.suggest "open #{the container}"
  else
    if container.is?(:openable) and container.is?(:open)
      actor.suggest "close #{the container}"
    end
    if container.is?(:open)
      actor.stream '<nav class="objects">'
      objects = container.children.that_are(:itemized)
      objects.each { |object|
        actor.stream Hypertext.link "look #{object}", object
      }
      actor.stream '</nav>'
    end
  end
end

respond :look, Query::Children.new(Clothing) do |actor, clothing|
  passthru
  if clothing.is?(:worn)
    actor.suggest "remove #{the clothing}"
  else
    actor.suggest "wear #{the clothing}"
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
  if actor.children.length > 0
    carried = actor.children.that_are_not(:worn)
    worn = actor.children.that_are(:worn)
    if carried.length > 0
      array = []
      carried.each { |entity|
        array << "#{Hypertext.link(entity.default_command, entity.indefinitely)}"
      }
      actor.tell "You are carrying #{array.join_and}."
    end
    if worn.length > 0
      array = []
      worn.each { |entity|
        array << "#{Hypertext.link(entity.default_command, entity.indefinitely)}"
      }
      actor.tell "You are wearing #{array.join_and}."
    end
    actor.stream '<nav class="objects">'
    actor.children.each { |object|
      actor.tell Hypertext.link "look #{object}", object.definitely
    }
    actor.stream '</nav>'
  else
    actor.tell "You aren't carrying anything."
  end
  actor[:checking_inventory] = true
end

respond :go, Query::Reachable.new(Door, :locked) do |actor, door|
  passthru
  if door.is? :locked
    actor.suggest "unlock #{the door}"
  end
end

respond :unlock, Query::Reachable.new(:lockable) do |actor, container|
  passthru
  if container.is?(:closed)
    actor.suggest "open #{the container}"
  end
end

respond :take, Query::Reachable.new(Clothing) do |actor, clothing|
  passthru
  if clothing.parent == actor
    actor.suggest "wear #{the clothing}"
  end
end

on_player_update do |actor|
  if actor.state_name != :active and actor.state.kind_of?(CharacterState::Active) == false
    next
  end
  if actor[:looking_at_room] != true
    actor.suggest "look around"
  end
  if actor[:checking_inventory] != true
    actor.suggest "inventory"
  end
  if actor.suggestions.length > 0
    actor.stream '<nav class="suggestions">'
    actor.stream "Suggestions: "
    actor.stream actor.suggestions.join(' ')
    actor.stream '</nav>'
    actor.suggestions.clear
  end
  entities = Query::Siblings.new.context_from(actor)
  portals = entities.that_are(Portal)
  if portals.length > 0
    actor.stream '<nav class="portals">'
    actor.stream "Exits: "
    portals.each { |portal|
      actor.stream Hypertext.link("go #{portal.direction}", "#{portal.direction}") + " "
    }
    actor.stream '</nav>'
  end
  if actor.room.is? :dark
    next
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
  objects = entities.that_are(:itemized) - characters - [actor] - portals
  if objects.length > 0
    actor.stream '<nav class="objects">'
    actor.stream "Objects: "
    objects.each { |entity|
      actor.stream Hypertext.link(entity.default_command, "#{the entity}") + " "
    }
    actor.stream '</nav>'
  end
  extras = entities.that_are(:not_itemized) - characters - [actor] - portals
  if extras.length > 0
    actor.stream '<nav class="incidentals">'
    actor.stream "Incidentals: "
    extras.each { |entity|
      actor.stream Hypertext.link("examine #{the entity}", "#{the entity}") + " "
    }
    actor.stream '</nav>'
  end
end
