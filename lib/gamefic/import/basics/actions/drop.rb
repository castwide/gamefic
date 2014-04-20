respond :drop, Query::Children.new() do |actor, thing|
  thing.parent = actor.parent
  actor.tell "You drop #{the thing}.", true
end

xlate "put down :thing", :drop, :thing
xlate "put :thing down", :drop, :thing

respond :drop, Query::Children.new(Thing), Query::Reachable.new(Supporter) do |actor, thing, supporter|
  thing.parent = supporter
  thing.is :supported
  actor.tell "You put #{the thing} on #{the supporter}."
end
respond :drop, Query::Family.new(Thing), Query::Reachable.new(Thing) do |actor, thing, supporter|
  actor.tell "You're not carrying #{thing}."
end
respond :drop, Query::Text.new(), Query::Text.new() do |actor, thing, supporter|
  actor.tell "You don't see anything called '#{thing}.'"
end
respond :drop, Query::Children.new(Thing), Query::Visible.new(Thing) do |actor, thing, target|
  if actor.parent != target.parent
    if actor.is?(:supported) or actor.is?(:container)
      actor.tell "You can't reach #{the target} from #{the actor.parent}."
      next
    end
  end
  passthru
end
respond :drop, Query::Children.new(Thing), Query::Siblings.new(Thing) do |actor, thing, supporter|
  actor.perform "drop #{thing}"
end
respond :drop, Query::Children.new(Thing), Query::Text.new() do |actor, thing, supporter|
  actor.tell "You don't see anything called '#{supporter}.'"
end
xlate "put :thing on :supporter", :drop, :thing, :supporter
xlate "put :thing down on :supporter", :drop, :thing, :supporter
xlate "set :thing on :supporter", :drop, :thing, :supporter
xlate "set :thing down on :supporter", :drop, :thing, :supporter
xlate "drop :thing on :supporter", :drop, :thing, :supporter
xlate "place :thing on :supporter", :drop, :thing, :supporter

respond :drop, Query::Children.new(), Query::Reachable.new(Container) do |actor, thing, container|
  if container.is? :closed
    actor.tell "#{The container} is closed."
  else
    thing.parent = container
    thing.is :contained
    actor.tell "You put #{the thing} in #{the container}."
  end
end
xlate "drop :item in :container", :drop, :item, :container
xlate "put :item in :container", :drop, :item, :container
xlate "place :item in :container", :drop, :item, :container
