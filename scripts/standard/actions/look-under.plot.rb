script 'standard/actions/look'

respond :look_under, Use.family() do |actor, thing|
  actor.tell "There's nothing to see under #{the thing}."
end

interpret "look beneath :thing", "look under :thing"
interpret "look below :thing", "look under :thing"
