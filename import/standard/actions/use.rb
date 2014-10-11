respond :use, Query::Reachable.new, Query::Reachable.new do |actor, tool, object|
  actor.perform "You're not carrying the #{tool}."
end

respond :use, Query::Children.new, Query::Text.new do |actor, tool, object|
  actor.perform "You don't see any '#{object}' here."
end

respond :use, Query::Text.new, Query::Reachable.new do |actor, tool, object|
  actor.perform "You don't have anything called '#{tool}.'"
end

respond :use, Query::Children.new, Query::Reachable.new do |actor, tool, object|
  actor.perform "I don't know how. (A more specific command might work.)"
end

xlate "use :tool on :object", :use, :tool, :object
