respond :close, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :close, Query::Reachable.new(Entity) do |actor, thing|
  actor.tell "You can't close #{the thing}."
end

respond :close, Query::Reachable.new(Container, :openable) do |actor, container|
  if container.is? :closed or container.is? :locked
    actor.tell "It's already closed."
  else
    actor.tell "You close #{the container}."
    container.is :closed
  end
end
