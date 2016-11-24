respond :insert, Use.text("all", "everything"), Use.reachable(Receptacle) do |actor, text, receptacle|
  children = actor.children.that_are_not(:attached?)
  if children.length == 0
    actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.be + ' not'} carrying anything to put in #{the receptacle}."
  else
    inserted = []
    children.each { |child|
      buffer = actor.quietly :insert, child, receptacle
      if child.parent != receptacle
        actor.tell buffer
      else
        inserted.push child
      end
    }
    if inserted.length > 0
      actor.tell "#{you.pronoun.Subj} put #{inserted.join_and} in #{the receptacle}."
    end
  end
end

respond :insert, Use.many_children, Use.reachable(Receptacle) do |actor, children, receptacle|
  inserted = []
  children.each { |child|
    buffer = actor.quietly :insert, child, receptacle
    if child.parent != receptacle
      actor.tell buffer
    else
      inserted.push child
    end
  }
  if inserted.length > 0
    actor.tell "#{you.pronoun.Subj} put #{inserted.join_and} in #{the receptacle}."
  end
end

respond :insert, Use.many_children, Use.reachable(Container) do |actor, children, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :insert, Use.any_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, children, receptacle|
  actor.perform :insert, children, receptacle
end

respond :insert, Use.text("everything", "all"), Use.text("except", "but"), Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, _, exceptions, receptacle|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :insert, children - exceptions, receptacle
end

respond :insert, Use.not_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, exceptions, receptacle|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :insert, children - exceptions, receptacle
end

respond :insert, Use.plural_children, Use.reachable(Receptacle) do |actor, children, receptacle|
  actor.perform :insert, children, receptacle
end
