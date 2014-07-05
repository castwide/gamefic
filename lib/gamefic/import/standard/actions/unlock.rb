respond :unlock, Query::Text.new() do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :unlock, Query::Reachable.new(Entity) do |actor, thing|
  actor.tell "You can't unlock #{the thing}."
end

respond :unlock, Query::Reachable.new(Container, :lockable) do |actor, container|
  # Portable containers need to be picked up before they are unlocked.
  if container.is? :portable and container.parent != actor
    actor.perform "take #{container}"
    if container.parent != actor
      break
    end
  end
  if container.is?(:locked) == false
    actor.tell "#{The container} isn't locked."
  else
    if container.is?(:auto_lockable)
      key = nil
      if container.key.nil? == false
        if container.key.parent == actor
          key = container.key
        end
      end
      if key.nil?
        actor.tell "You don't have any way to unlock #{the container}."
      else
        actor.tell "You unlock #{the container} with #{the key}."
        container.is :closed
      end
    else
      actor.tell "What do you want to unlock #{the container} with?"
    end
  end
end

respond :unlock, Query::Reachable.new(Container, :lockable), Query::Children.new do |actor, container, key|
  if container.is?(:locked)
    if container.key == key
      if container.is?(:not_auto_lockable)
        container.is :auto_lockable
        actor.perform "unlock #{container}"
        container.is :not_auto_lockable
      else
        actor.perform "unlock #{container}"      
      end
    else
      actor.tell "You can't unlock #{the container} with #{the key}."
    end
  else
    actor.tell "#{The container} isn't locked."
  end
end

xlate "unlock :container with :key", :unlock, :container, :key
