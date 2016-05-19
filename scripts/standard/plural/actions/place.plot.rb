respond :place, Use.many_children, Use.reachable(Supporter) do |actor, children, supporter|
  placed = []
  children.each { |child|
    buffer = actor.quietly :place, child, supporter
    if child.parent != supporter
      actor.tell buffer
    else
      placed.push child
    end
  }
  if placed.length > 0
    actor.tell "You put #{placed.join_and} on #{the supporter}."
  end
end

respond :place, Use.any_expression, Use.ambiguous_children, Use.reachable(Supporter) do |actor, _, children, supporter|
  actor.perform :place, children, supporter
end

respond :place, Use.text("all", "everything"), Use.reachable(Supporter) do |actor, _, supporter|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :place, children, supporter
end

respond :place, Use.text("all", "everything"), Use.text("except", "but"), Use.ambiguous_children, Use.reachable(Supporter) do |actor, _, _, exceptions, supporter|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :place, children - exceptions, supporter
end

respond :place, Use.not_expression, Use.ambiguous_children, Use.reachable(Supporter) do |actor, _, exceptions, supporter|
  children = Use.children.context_from(actor).that_are_not(:attached?)
  actor.perform :place, children - exceptions, supporter
end

respond :place, Use.plural_children, Use.reachable(Supporter) do |actor, children, supporter|
  actor.perform :place, children, supporter
end
