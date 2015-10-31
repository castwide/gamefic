require 'standard'

respond :insert, Use.visible, Use.reachable do |actor, thing, target|
  actor.tell "You can't put #{the thing} inside #{the target}."
end

respond :insert, Use.visible, Use.reachable(Receptacle) do |actor, thing, receptacle|
  if actor.auto_takes?(thing)
    actor.tell "You put #{the thing} in #{the receptacle}."
    thing.parent = receptacle
  end
end

respond :insert, Use.visible, Use.reachable(Container) do |actor, thing, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :insert, Use.visible, Use.text do |actor, thing, container|
  actor.tell "You don't see anything called \"#{container}\" here."
end

respond :insert, Use.text, Use.visible do |actor, thing, container|
  actor.tell "You don't see anything called \"#{thing}\" here."
end

respond :insert, Use.text, Use.text do |actor, thing, container|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{container}.\""
end

respond :insert, Use.text("all", "everything"), Use.reachable(Receptacle) do |actor, text, receptacle|
  children = actor.children.that_are_not(:attached?)
  if children.length == 0
    actor.tell "You're not carrying anything to put in #{the receptacle}."
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
      actor.tell "You put #{inserted.join_and} in #{the receptacle}."
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
    actor.tell "You put #{inserted.join_and} in #{the receptacle}."
  end
end

respond :insert, Use.many_children, Use.reachable(Container) do |actor, children, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :insert, Use.any_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, children, _, receptacle|
  actor.perform :insert, children, receptacle
end

respond :insert, Use.any_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, children, _, receptacle|
  actor.perform :insert, children, receptacle
end

respond :insert, Use.text("everything", "all"), Use.text("except", "but"), Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, _, exceptions, receptacle|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :insert, children - exceptions, receptacle
end

respond :insert, Use.any_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, children, receptacle|
  actor.perform :insert, children, receptacle
end

respond :insert, Use.not_expression, Use.ambiguous_children, Use.reachable(Receptacle) do |actor, _, exceptions, receptacle|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :insert, children - exceptions, receptacle
end

respond :insert, Use.plural_children, Use.reachable(Receptacle) do |actor, children, receptacle|
  actor.perform :insert, children, receptacle
end

interpret "drop :item in :container", "insert :item :container"
interpret "put :item in :container", "insert :item :container"
interpret "place :item in :container", "insert :item :container"
interpret "insert :item in :container", "insert :item :container"

interpret "drop :item inside :container", "insert :item :container"
interpret "put :item inside :container", "insert :item :container"
interpret "place :item inside :container", "insert :item :container"
interpret "insert :item inside :container", "insert :item :container"

interpret "drop :item into :container", "insert :item :container"
interpret "put :item into :container", "insert :item :container"
interpret "place :item into :container", "insert :item :container"
interpret "insert :item into :container", "insert :item :container"
