module Gamefic::Suggestible
  def suggestions
    @suggestions ||= []
  end
  def suggest command
    if !suggestions.include?(command)
      suggestions.push command
    end
  end
  def suggest_from entity
    suggest_take_from entity
    suggest_examine_from entity
  end
  def suggest_take_from entity
    portables = entity.children.that_are(:portable?)
    portables.each { |p|
      suggest "take #{p.definitely}"
    }
    if portables.length > 1
      suggest "take everything"
    end
  end
  def suggest_examine_from entity
    entity.children.that_are_not(Portal).that_are_not(self).each { |e|
      suggest "examine #{e.definitely}"
    }
  end
end
