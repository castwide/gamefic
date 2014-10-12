respond :read, Query::Visible.new do |actor, thing|
  actor.perform :look, thing
end
