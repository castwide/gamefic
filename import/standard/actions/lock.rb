respond :lock, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :lock, Query::Reachable.new(Entity) do |actor, thing|
  actor.tell "You can't lock #{the thing}."
end

respond :lock, Query::Reachable.new(Container, :lockable) do |actor, container|
  # Portable containers need to be picked up before they are locked.
  if container.is? :portable and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if container.is?(:locked)
    actor.tell "It's already locked."
  else
    if container.is?(:auto_lockable)
      key = nil
      if container.key.nil? == false
        if container.key.parent == actor
          key = container.key
        end
      end
      if key.nil?
        actor.tell "You don't have any way to lock #{the container}."
      else
        actor.tell "You lock #{the container} with #{the key}."
        container.is :locked
      end
    else
      actor.tell "What do you want to lock #{the container} with?"
    end
  end
end

respond :lock, Query::Reachable.new(Container, :lockable), Query::Children.new do |actor, container, key|
  if container.is?(:locked) == false
    if container.key == key
      if container.is?(:not_auto_lockable)
        container.is :auto_lockable
        actor.perform :lock, container
        container.is :not_auto_lockable
      else
        actor.perform :lock, container
      end
    else
      actor.tell "You can't lock #{the container} with #{the key}."
    end
  else
    actor.tell "It's already locked."
  end
end

xlate "lock :container with :key", :lock, :container, :key
