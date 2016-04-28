respond :unlock, Query::Text.new() do |actor, string|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any \"#{string}\" here."
end

respond :unlock, Query::Reachable.new() do |actor, thing|
  actor.tell "#{you.pronoun.Subj} can't unlock #{the thing}."
end

respond :unlock, Query::Reachable.new(Lockable) do |actor, container|
  # Portable containers need to be picked up before they are unlocked.
  if container.portable? and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if container.locked? == false
    actor.tell "#{The container} isn't locked."
  else
    #if container.is?(:auto_lockable)
      key = nil
      if container.lock_key.nil? == false
        if container.lock_key.parent == actor
          key = container.lock_key
        end
      end
      if key.nil?
        actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} have any way to unlock #{the container}."
      else
        actor.tell "#{you.pronoun.Subj} #{you.verb.unlock} #{the container} with #{the key}."
        container.locked = false
      end
    #takeelse
    #  actor.tell "What do you want to unlock #{the container} with?"
    #end
  end
end

respond :unlock, Query::Reachable.new(Lockable), Query::Text.new do |actor, container, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} have anything called '#{thing}.'"
end

respond :unlock, Query::Reachable.new(Lockable, :has_lock_key?), Query::Children.new do |actor, container, key|
  if container.is?(:locked)
    if container.key == key
      #if container.is?(:not_auto_lockable)
      #  container.is :auto_lockable
      #  actor.perform :unlock, container
      #  container.is :not_auto_lockable
      #else
        actor.perform :unlock, container
      #end
    else
      actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} unlock #{the container} with #{the key}."
    end
  else
    actor.tell "#{The container} isn't locked."
  end
end

respond :open, Query::Reachable.new(Lockable, :has_lock_key?), Query::Children.new do |actor, container, key|
  if container.is?(:locked)
    actor.perform :unlock, container, key
    if !container.is?(:locked)
      actor.perform :open, container
    end
  else
    actor.perform :open, container
  end
end

respond :use, Query::Children.new, Query::Reachable.new(Lockable, :has_lock_key?) do |actor, key, container|
  actor.perform :unlock, container, key
end

xlate "unlock :container with :key", "unlock :container :key"
xlate "open :container with :key", "open :container :key"
