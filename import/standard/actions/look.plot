respond :look, Query::Parent.new(Supporter) do |actor, supporter|
  actor.tell supporter.description
  actor.tell "You are currently on #{the supporter}."
end

respond :look, Query::Room.new(Room) do |actor, room|
  actor.tell "<strong>#{room.name.cap_first}</strong>"
  actor.tell room.description
  with_locales = []
  chars = room.children.that_are(Character).that_are(:itemized) - [actor]
  charsum = []
  chars.each { |char|
    if char.locale_description != ""
      with_locales.push char
    else
      charsum.push char
    end
  }
  if charsum.length > 0
    actor.tell "#{charsum.join_and.cap_first} #{charsum.length == 1 ? 'is' : 'are'} here."
  end
  items = room.children.that_are(:itemized) - [actor] - room.children.that_are(Character)
  itemsum = []
  items.each { |item|
    if item.locale_description != ""
      with_locales.push item
    else
      itemsum.push item
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
        actor.tell "There is an exit #{portals[0].direction}."
      else
        dirs = []
        portals.each { |p|
          dirs.push p.direction
        }
        actor.tell "There are exits #{dirs.join_and(', ')}."
      end
    end
  end
  if actor.is? :supported
    actor.tell "You are on #{the actor.parent}."
    actor.parent.children.that_are(:supported).that_are_not(actor).each { |s|
      actor.tell "#{A s} is on #{the actor.parent}."
    }
  end
end
xlate "look", :look, "around"
xlate "l", :look, "around"

respond :look, Query::Visible.new() do |actor, thing|
  actor.tell thing.description
  thing.children.that_are(:attached).that_are(:itemized).each { |item|
    actor.tell "#{An item} is attached to #{the thing}."
  }
end

respond :look, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :look, Query::Reachable.new(Container) do |actor, container|
  actor.proceed
  if container.is? :openable
    actor.tell "#{The container} is #{container.is?(:open) ? 'open' : 'closed'}."
  end
  if container.is? :open
    contents = container.children.that_are(:contained)
    if contents.length > 0
      actor.tell "You see #{contents.join_and} inside #{the container}."
    end
  end
end

respond :look, Query::Visible.new(Supporter) do |actor, supporter|
  actor.proceed
  supported = supporter.children.that_are(:supported)
  if supported.length > 0
    actor.tell "You see #{supported.join_and} sitting there."
  end
end

respond :look, Query::Reachable.new(Door, :openable) do |actor, door|
  if door.has_description?
    actor.proceed
  end
  actor.tell "#{The door} is " + ((door.is?(:open) and door.is?(:not_locked)) ? 'open' : 'closed') + '.'
end

xlate "look at :thing", "look :thing"
xlate "l :thing", "look :thing"
xlate "examine :thing", "look :thing"
xlate "x :thing", "look :thing"
xlate "search :thing", "look :thing"
