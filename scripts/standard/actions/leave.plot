respond :leave, Use.parent(Container, :enterable?) do |actor, container|
  if container.open?
    actor.proceed
  else
    actor.tell "#{The container} is closed."
  end
end

respond :leave, Use.parent do |actor, thing|
  actor.tell "There's no way out of #{the thing}."
end

respond :leave, Use.parent(Enterable, :enterable?) do |actor, thing|
  actor.tell "#{you.pronoun.Subj} #{you.verb[thing.leave_verb]} #{the thing}."
  actor.parent = thing.parent
end

respond :leave, Query::Parent.new(Room) do |actor, room|
  portals = room.children.that_are(Portal)
  if portals.length == 0
    actor.tell "#{you.pronoun.Subj} #{you.contract you.verb.do + ' not'} see any obvious exits."
  elsif portals.length == 1
    actor.perform :go, portals[0]
  else
    actor.tell "I don't know which way you want to go: #{portals.join_or}."
  end
end

respond :leave do |actor|
  actor.perform :leave, actor.parent
end

xlate "exit", "leave"
xlate "exit :supporter", "leave :supporter"
xlate "get off :supporter", "leave :supporter"
xlate "get up from :supporter", "leave :supporter"
xlate "get up", "leave"
xlate "get off", "leave"
xlate "get out :container", "leave :container"
xlate "get out of :container", "leave :container"
#xlate "out", "leave"
