respond :open, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :open, Query::Reachable.new() do |actor, thing|
  actor.tell "You can't open #{the thing}."
end

respond :open, Query::Reachable.new(:openable) do |actor, container|
  # Portable containers need to be picked up before they are opened.
  if container.is? :portable and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if container.is? :locked
    actor.tell "#{The container} is locked."
  elsif container.is? :closed
    actor.tell "You open #{the container}."
    container.is :open
  else
    actor.tell "It's already open."
  end
end
