respond :open, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :open, Query::Reachable.new() do |actor, thing|
  actor.tell "You can't open #{the thing}."
end

respond :open, Query::Reachable.new(Portable, Openable) do |actor, container|
  # Portable containers need to be picked up before they are opened.
  if container.portable? and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if container.locked?
    actor.tell "#{The container} is locked."
  elsif !container.open?
    actor.tell "You open #{the container}."
    container.open = true
    actor.perform :search, container
  else
    actor.tell "It's already open."
  end
end

respond :open, Query::Reachable.new(Container) do |actor, container|
  actor.proceed
  if container.open?
    actor.perform :search, container
  end
end
