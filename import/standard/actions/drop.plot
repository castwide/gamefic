respond :drop, Query::Visible.new() do |actor, thing|
  actor.tell "You're not carrying #{the thing}."
end

respond :drop, Query::Children.new() do |actor, thing|
  thing.parent = actor.parent
  actor.tell "You drop #{the thing}."
end

respond :drop, Use.many_visible do |actor, things|
  things.each { |thing|
    actor.perform :drop, thing
  }
end

interpret "put down :thing", "drop :thing"
interpret "put :thing down", "drop :thing"
