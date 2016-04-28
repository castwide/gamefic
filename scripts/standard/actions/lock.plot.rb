respond :lock, Query::Text.new() do |actor, string|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any \"#{string}\" here."
end

respond :lock, Query::Reachable.new() do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} lock #{the thing}."
end

respond :lock, Query::Reachable.new(Lockable, :has_lock_key?) do |actor, container|
  # Portable containers need to be picked up before they are locked.
  if container.portable? and container.parent != actor
    actor.perform :take, container
    if container.parent != actor
      break
    end
  end
  if container.locked?
    actor.tell "It's already locked."
  else
    #if container.is?(:auto_lockable)
      key = nil
      if container.lock_key.nil? == false
        if container.lock_key.parent == actor
          key = container.lock_key
        end
      end
      if key.nil?
        actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} have any way to lock #{the container}."
      else
        actor.tell "#{you.pronoun.Subj} #{you.verb.lock} #{the container} with #{the key}."
        container.locked = true
      end
    #else
    #  actor.tell "What do you want to lock #{the container} with?"
    #end
  end
end

respond :lock, Query::Reachable.new(Lockable, :has_lock_key?), Query::Children.new do |actor, container, key|
  if container.locked == false
    if container.lock_key == key
      #if container.is?(:not_auto_lockable)
      #  container.is :auto_lockable
      #  actor.perform :lock, container
      #  container.is :not_auto_lockable
      #else
      #  actor.perform :lock, container
      #end
      actor.tell "#{you.pronoun.Subj} #{you.verb.lock} #{the container} with #{the key}."
      container.locked = true
    else
      actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.can + ' not'} lock #{the container} with #{the key}."
    end
  else
    actor.tell "It's already locked."
  end
end

xlate "lock :container with :key", "lock :container :key"
