respond :look_under, Query::Reachable.new() do |actor, thing|
  actor.tell "There's nothing to see under #{the thing}."
end
