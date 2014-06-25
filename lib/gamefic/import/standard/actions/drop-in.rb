respond :drop_in, Query::Children.new(), Query::Reachable.new() do |actor, thing, target|
  puts "You can't put #{the thing} inside #{the target}."
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

xlate "drop :item in :container", :drop_in, :item, :container
xlate "put :item in :container", :drop_in, :item, :container
xlate "place :item in :container", :drop_in, :item, :container
