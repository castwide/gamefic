respond :go, Query::Reachable.new(Portal) do |actor, portal|
  if actor.parent != actor.room
    actor.perform :leave
  end
  if actor.parent == actor.room
    if portal.destination.nil?
      actor.tell "That portal leads nowhere."
    else
      actor.parent = portal.destination
      actor.tell "You go #{portal.direction}."
      actor.perform :look, actor.room
    end
  end
end

respond :go, Query::Reachable.new(Door) do |actor, door|
  if door.is? :locked
    actor.tell "It's locked."
  else
    if door.is? :closed and door.is? :automatic
      actor.perform :open, door
    end
    if door.is? :open
      actor.proceed
    end
  end
end

respond :go, Query::Reachable.new(Door, :closed, :not_automatic) do |actor, door|
  actor.tell "#{The door} is closed."
end

respond :go, Query::Text.new() do |actor, string|
  actor.tell "You don't see any exit \"#{string}\" from here."
end

respond :go do |actor|
  actor.tell "Where do you want to go?"
end

xlate "north", "go north"
xlate "south", "go south"
xlate "west", "go west"
xlate "east", "go east"
xlate "up", "go up"
xlate "down", "go down"
xlate "northwest", "go northwest"
xlate "northeast", "go northeast"
xlate "southwest", "go southwest"
xlate "southeast", "go southeast"

xlate "n", "go north"
xlate "s", "go south"
xlate "w", "go west"
xlate "e", "go east"
xlate "u", "go up"
xlate "d", "go down"
xlate "nw", "go northwest"
xlate "ne", "go northeast"
xlate "sw", "go southwest"
xlate "se", "go southeast"
