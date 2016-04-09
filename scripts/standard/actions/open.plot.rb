respond :open, Use.text do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :open, Use.reachable() do |actor, thing|
  actor.tell "You can't open #{the thing}."
end

respond :open, Use.reachable(Openable) do |actor, container|
  # Portable containers need to be picked up before they are opened.
  if container.portable? and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if !container.open?
    actor.tell "You open #{the container}."
    container.open = true
    if container.children.that_are_not(:attached?).length > 0
      actor.perform :search, container
    end
  else
    actor.tell "It's already open."
  end
end

respond :open, Use.reachable(Openable, Lockable) do |actor, container|
  if container.locked?
    actor.tell "#{The container} is locked."
  else
    actor.proceed
  end
end
