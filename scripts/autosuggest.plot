require 'autosuggest/suggestible'

class Gamefic::Character
  include Suggestible
end

on_player_update do |actor|
  if actor.scene.key == :active
    actor.suggest "look around"
    actor.suggest "inventory"
    actor.room.children.that_are(Portal).each { |entity|
      if entity.direction
        actor.suggest "go #{entity.direction}"
      else
        actor.suggest "go to #{the entity}"
      end
    }
    Use.siblings.context_from(actor).that_are(Enterable).that_are(:enterable?).each { |entity|
      actor.suggest "#{entity.enter_verb} #{the entity}"
    }
    if (actor.parent != actor.room)
      actor.suggest "#{actor.parent.leave_verb} #{the actor.parent}"
    end
    vicinity = actor.parent.children.that_are_not(Portal)
    if actor.parent != actor.room
      vicinity.concat actor.room.children.that_are_not(Portal)
    end
    vicinity.each { |e|
      actor.suggest "examine #{the e}"
    }
  end
end

on_update do
  players.each { |player|
    player.suggestions.each { |s|
      player.stream "<a class=\"suggestion\" href=\"#\" rel=\"gamefic\" data-command=\"#{s.cap_first}\">#{s.cap_first}</a>"
    }
    player.suggestions.clear
  }
end

respond :look, Use.visible(Supporter) do |actor, supporter|
  actor.proceed
  actor.suggest_from supporter
end

respond :look, Use.visible(Receptacle) do |actor, receptacle|
  actor.proceed
  # Include suggestions from the receptacle if they're visible
  # (e.g., the receptacle is not a closed opaque container) 
  available = Use.visible.context_from(actor) & receptacle.children
  if available.length > 0
    actor.suggest_from receptacle
  end
end

respond :look, Use.visible(Container) do |actor, container|
  actor.proceed
  if container.open?
    actor.suggest "close #{the container}"
  else
    if container.locked?
      actor.suggest "unlock #{the container}"
    else
      actor.suggest "open #{the container}"
      if !container.lock_key.nil?
        actor.suggest "lock #{the container}"
      end
    end
  end
end

respond :look, Use.room do |actor, room|
  actor.proceed
  actor.suggest_from room
end

respond :look, Use.visible(:portable?) do |actor, thing|
  actor.proceed
  actor.suggest "take #{the thing}"
end

respond :inventory do |actor|
  actor.proceed
  carried = actor.children.that_are_not(:attached?)
  carried.each { |e|
    actor.suggest "drop #{the e}"
    actor.suggest "examine #{the e}"  
  }
  if carried.length > 1
    actor.suggest "drop everything"
  end
  reachable = Use.reachable.context_from(actor)
  reachable.that_are(Supporter).each { |supporter|
    carried.each { |thing|
      actor.suggest "put #{the thing} on #{the supporter}"
    }
  }
  reachable.that_are(Receptacle).each { |receptacle|
    carried.each { |thing|
      actor.suggest "put #{the thing} in #{the receptacle}"
    }
  }
end

respond :drop, Use.children do |actor, thing|
  actor.proceed
  actor.quietly :inventory
end

respond :search, Use.reachable(Receptacle) do |actor, receptacle|
  actor.proceed
  actor.children.that_are_not(:attached?).each { |e|
    actor.suggest "put #{the e} in #{the receptacle}"
  }
end

respond :search, Use.reachable(Container) do |actor, container|
  if container.open?
    actor.proceed
  else
    if container.has_description?
      actor.tell container.description
    end
    if container.locked?
      actor.tell "#{The container} is locked."
      actor.suggest "unlock #{the container}"
    else
      actor.tell "#{The container} is closed."
      actor.suggest "open #{the container}"
    end
  end
end
