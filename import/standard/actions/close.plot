respond :close, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :close, Query::Reachable.new() do |actor, thing|
  actor.tell "You can't close #{the thing}."
end

respond :close, Query::Reachable.new(Gamefic::Openable) do |actor, container|
  if !container.open?
    actor.tell "It's already closed."
  else
    actor.tell "You close #{the container}."
    container.open = false
  end
end
