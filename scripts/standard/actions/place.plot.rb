respond :place, Use.children, Use.reachable do |actor, thing, supporter|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.can + ' not')} put #{the thing} on #{the supporter}."
end

respond :place, Use.visible, Use.reachable(Supporter) do |actor, thing, supporter|
  if thing.parent != actor
    actor.perform :take, thing
  end
  if thing.parent == actor
    actor.perform :place, thing
  end
end

respond :place, Use.children, Use.reachable(Supporter) do |actor, thing, supporter|
  thing.parent = supporter
  actor.tell "#{you.pronoun.Subj} #{you.verb.put} #{the thing} on #{the supporter}."
end

respond :place, Use.visible, Use.text do |actor, thing, supporter|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see anything called \"#{supporter}\" here."
end

respond :place, Use.text, Use.visible do |actor, thing, supporter|
  actor.tell "#{you.pronoun.Subj} #{you.contract(you.verb.do + ' not')} see anything called \"#{thing}\" here."
end

respond :place, Use.text, Use.text do |actor, thing, supporter|
  actor.tell "I don't know what you mean by \"#{thing}\" or \"#{supporter}.\""
end

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

xlate "put :thing on :supporter", "place :thing :supporter"
xlate "put :thing down on :supporter", "place :thing :supporter"
xlate "set :thing on :supporter", "place :thing :supporter"
xlate "set :thing down on :supporter", "place :thing :supporter"
xlate "drop :thing on :supporter", "place :thing :supporter"
xlate "place :thing on :supporter", "place :thing :supporter"
