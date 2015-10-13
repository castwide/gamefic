#respond :take, Query::Text.new() do |actor, thing|
#  actor.tell "I don't see anything called '#{thing}' here."
#end

respond :take, Use.reachable do |actor, thing|
  actor.tell "You can't take #{the thing}."
end

respond :take, Query::Reachable.new(Entity, :portable?) do |actor, thing|
  thing.parent = actor
  actor.tell "You take #{the thing}."
end

respond :take, Query::Visible.new() do |actor, thing|
  if thing.parent == actor.parent
    actor.proceed
  elsif thing.parent.kind_of?(Container) and !thing.parent.open?
    actor.tell "#{The thing} is inside #{the thing.parent}, which is closed."
  end
end

respond :take, Query::Visible.new() do |actor, thing|
  if actor.parent.kind_of?(Supporter) and actor.parent != thing.parent and actor.parent != thing.parent.parent
    actor.tell "You can't reach it from #{the actor.parent}."
  else
    actor.proceed
  end
end

respond :take, Query::Reachable.new(:attached?) do |actor, thing|
  actor.tell "#{The thing} is attached to #{the thing.parent}."
end

#respond :take, Query::Reachable.new(Portable, :portable?) do |actor, thing|
#  if thing.parent != actor.parent
#    if thing.parent.kind_of?(Container) and !thing.parent.open?
#      if thing.parent.transparent?
#        actor.tell "#{The thing} is closed."
#      else
#        actor.proceed
#      end
#      break
#    end
#    actor.tell "You take #{the thing} from #{the thing.parent}."
#    thing.parent = actor
#  else
#    actor.proceed
#  end
#end

respond :take, Query::Reachable.new(Entity, :portable?) do |actor, thing|
  if actor.parent != thing.parent
    actor.tell "You take #{the thing} from #{the thing.parent}."
    thing.parent = actor
  else
    actor.proceed
  end
end

respond :take, Gamefic::Query::Children.new() do |actor, thing|
  actor.tell "You're already carrying #{the thing}."
end

respond :take, Use.reachable(Gamefic::Rubble) do |actor, rubble|
  actor.tell "You don't have any use for #{the rubble}."
end

respond :take, Use.text do |actor, text|
  actor.tell "You don't see any \"#{text}\" here."
end

respond :take, Use.many_visible do |actor, things|
  things.each { |thing|
    actor.perform :take, thing
  }
end

interpret "get :thing", "take :thing"
interpret "pick up :thing", "take :thing"
interpret "pick :thing up", "take :thing"
interpret "carry :thing", "take :thing"
