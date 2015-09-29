respond :insert, Use.children, Use.reachable do |actor, thing, target|
  actor.tell "You can't put #{the thing} inside #{the target}."
end

respond :insert, Use.visible, Use.reachable(Container) do |actor, thing, container|
  if thing.parent != actor
    actor.perform :take, thing
  end
  if thing.parent == actor
    actor.perform :drop_in, thing, container
  end
end

respond :insert, Use.children, Use.reachable(Container) do |actor, thing, container|
  if !container.open?
    actor.tell "#{The container} is closed."
  else
    thing.parent = container
    actor.tell "You put #{the thing} in #{the container}."
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

xlate "drop :item in :container", "insert :item :container"
xlate "put :item in :container", "insert :item :container"
xlate "place :item in :container", "insert :item :container"
