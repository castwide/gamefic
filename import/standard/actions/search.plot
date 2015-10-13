respond :search, Use.reachable(Receptacle) do |actor, receptacle|
  # TODO Show the contents of the receptacle
  contents = receptacle.children.that_are_not(:attached?)
  if contents.length > 0
    actor.tell "Inside #{contents.length > 1 ? 'are' : 'is'} #{contents.join_and}."
  else
    actor.tell "#{The receptacle} #{receptacle.verb.be} empty."
  end
end

respond :search, Use.reachable(Container) do |actor, container|
  if container.open? or container.transparent?
    actor.proceed
  else
    actor.tell "#{The container} #{container.verb.be} closed."
  end
end

respond :search, Use.reachable do |actor, thing|
  actor.perform :look, thing
end
