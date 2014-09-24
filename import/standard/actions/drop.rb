respond :drop, Query::Visible.new() do |actor, thing|
  actor.tell "You're not carrying #{the thing}."
end

respond :drop, Query::Children.new() do |actor, thing|
  thing.parent = actor.parent
  actor.tell "You drop #{the thing}."
end

xlate "put down :thing", :drop, :thing
xlate "put :thing down", :drop, :thing

#respond :drop, Query::Family.new(Thing), Query::Reachable.new(Thing) do |actor, thing, supporter|
#  actor.tell "You're not carrying #{thing}."
#end
#respond :drop, Query::Text.new(), Query::Text.new() do |actor, thing, supporter|
#  actor.tell "You don't see anything called '#{thing}.'"
#end
#respond :drop, Query::Children.new(Thing), Query::Visible.new(Thing) do |actor, thing, target|
#  if actor.parent != target.parent
#    if actor.is?(:supported) or actor.is?(:container)
#      actor.tell "You can't reach #{the target} from #{the actor.parent}."
#      next
#    end
#  end
#  passthru
#end
#respond :drop, Query::Children.new(Thing), Query::Text.new() do |actor, thing, supporter|
#  actor.tell "You don't see anything called '#{supporter}.'"
#end
