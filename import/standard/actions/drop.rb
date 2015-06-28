respond :drop, Query::Visible.new() do |actor, thing|
  actor.tell "You're not carrying #{the thing}."
end

respond :drop, Query::Children.new() do |actor, thing|
  thing.parent = actor.parent
  actor.tell "You drop #{the thing}."
end

xlate "put down :thing", "drop :thing"
xlate "put :thing down", "drop :thing"
