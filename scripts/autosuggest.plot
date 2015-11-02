require 'autosuggest/suggestible'

class Gamefic::Character
  include Suggestible
end

on_player_update do |actor|
  if actor.scene.key == :active
    actor.suggest "look around"
    actor.suggest "inventory"
    if Use.visible.context_from(actor).length > 0
      actor.suggest "take everything"
    end
    actor.room.children.that_are(Portal).each { |entity|
      if entity.direction
        actor.suggest "go #{entity.direction}"
      else
        actor.suggest "go to #{the entity}"
      end
    }
    Use.visible.context_from(actor).that_are_not(Portal).each { |entity|
      actor.suggest "examine #{the entity}"
    }
    Use.visible.context_from(actor).that_are(:portable?).each { |entity|
      actor.suggest "take #{the entity}"
    }
    Use.visible.context_from(actor).that_are(Container).that_are_not(:open?).each { |entity|
      actor.suggest "close #{the entity}"
    }
    Use.visible.context_from(actor).that_are(Container).that_are(:open?).each { |entity|
      actor.suggest "search #{the entity}"
      actor.suggest "close #{the entity}"
    }
    Use.siblings.context_from(actor).that_are(Enterable).that_are(:enterable?).each { |entity|
      actor.suggest "#{entity.enter_verb} #{the entity}"
    }
    if (actor.parent != actor.room)
      actor.suggest "#{actor.parent.leave_verb} #{the actor.parent}"
    end
    actor.children.that_are_not(:attached?).each { |entity|
      actor.suggest "drop #{the entity}"
      Use.siblings.context_from(actor).that_are(Supporter).each { |supporter|
        actor.suggest "put #{the entity} on #{the supporter}"
      }
      Use.siblings.context_from(actor).that_are(Receptacle).each { |receptacle|
        actor.suggest "put #{the entity} in #{the receptacle}"
      }
    }
    if actor.children.that_are_not(:attached?).length > 0
      actor.suggest "drop everything"
      Use.siblings.context_from(actor).that_are(Supporter).each { |supporter|
        actor.suggest "put everything on #{the supporter}"
      }
      Use.siblings.context_from(actor).that_are(Receptacle).each { |receptacle|
        actor.suggest "put everything in #{the receptacle}"
      }
    end
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
