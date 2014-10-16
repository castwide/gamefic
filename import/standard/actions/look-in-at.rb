respond :look_in_at, Query::Text.new(), Query::Text.new() do |actor, container, thing|
  actor.tell "You don't see any '#{container}' here."
end

respond :look_in_at, Query::Reachable.new(), Query::Text.new() do |actor, container, thing|
  actor.tell "You don't see any '#{thing}' in #{the container}."
end

respond :look_in_at, Query::Reachable.new(), Query::Subquery.new() do |actor, container, thing|
  if thing.is?(:supported) or thing.is?(:attached) or ( thing.is?(:contained) and (container.is?(:open) or container.is?(:transparent)) )
    actor.perform :look, thing
  elsif container.is?(:closed)
    actor.tell "#{The container} is closed."
  else
    passthru
  end
end

xlate "look in :container at :thing", "look_in_at :container :thing"
xlate "l in :container at :thing", "look_in_at :container :thing"

xlate "look :thing in :container", "look_in_at :container :thing"
xlate "look at :thing in :container", "look_in_at :container :thing"
xlate "l :thing in :container", "look_in_at :container :thing"
xlate "examine :thing in :container", "look_in_at :container :thing"
xlate "exam :thing in :container", "look_in_at :container :thing"
xlate "x :thing in :container", "look_in_at :container :thing"
