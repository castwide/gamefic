respond :read, Use.family do |actor, thing|
  actor.perform :look, thing
end
