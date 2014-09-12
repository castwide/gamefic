respond :drop_in, Query::Children.new(), Query::Reachable.new() do |actor, thing, target|
  puts "You can't put #{the thing} inside #{the target}."
end

respond :drop_in, Query::Visible.new(), Query::Reachable.new(Container) do |actor, thing, container|
  if thing.parent != actor
    actor.perform :take, thing
  end
  if thing.parent == actor
    actor.perform :drop_in, thing, container
  end
end

respond :drop_in, Query::Children.new(), Query::Reachable.new(Container) do |actor, thing, container|
  if container.is? :closed
    actor.tell "#{The container} is closed."
  else
    thing.parent = container
    thing.is :contained
    actor.tell "You put #{the thing} in #{the container}."
  end
end

respond :drop_in, Query::Visible.new(), Query::Text.new() do |actor, thing, container|
  actor.tell "You don't see anything called \"#{container}\" here."
end

respond :drop_in, Query::Text.new(), Query::Visible.new() do |actor, thing, container|
  actor.tell "You don't see anything called \"#{thing}\" here."
end

respond :drop_in, Query::Text.new(), Query::Text.new() do |actor, thing, container|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{container}.\""
end

xlate "drop :item in :container", :drop_in, :item, :container
xlate "put :item in :container", :drop_in, :item, :container
xlate "place :item in :container", :drop_in, :item, :container
