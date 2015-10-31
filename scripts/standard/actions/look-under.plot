require 'standard/actions/look'

respond :look_under, Query::Reachable.new() do |actor, thing|
  actor.tell "There's nothing to see under #{the thing}."
end

interpret "look beneath :thing", "look under :thing"
interpret "look below :thing", "look under :thing"
