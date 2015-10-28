require 'gamefic';module Gamefic;respond :use, Query::Reachable.new do |actor, tool|
  actor.tell "I don't know how. (A more specific command might work.)"
end

respond :use, Gamefic::Query::Text.new do |actor, thing|
  actor.tell "You don't see any '#{thing}' you can use here."
end

respond :use, Query::Reachable.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "You're not carrying the #{tool}."
end

respond :use, Gamefic::Query::Children.new, Gamefic::Query::Text.new do |actor, tool, object|
  actor.tell "You don't see any '#{object}' here."
end

respond :use, Query::Text.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "You don't have anything called '#{tool}.'"
end

respond :use, Query::Children.new, Query::Reachable.new do |actor, tool, object|
  actor.tell "I don't know how. (A more specific command might work.)"
end

xlate "use :tool on :object", "use :tool :object"
;end
