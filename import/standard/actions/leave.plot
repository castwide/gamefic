respond :leave, Query::Parent.new(Supporter) do |actor, supporter|
  actor.parent = supporter.parent
  actor.tell "You get off #{the supporter}."
end
respond :leave, Query::Parent.new(Container) do |actor, supporter|
  actor.parent = supporter.parent
  actor.tell "You get out of #{the supporter}."
end
respond :leave, Query::Parent.new(Room) do |actor, room|
  portals = room.children.that_are(Portal)
  if portals.length == 0
    actor.tell "You don't see any obvious exits."
  elsif portals.length == 1
    actor.perform :go, portals[0]
  else
    actor.tell "I don't know which way you want to go: #{portals.join_and(', ', ' or ')}."
  end
end
respond :leave do |actor|
  actor.perform :leave, actor.parent
end
xlate "exit", :leave
xlate "exit :supporter", "leave :supporter"
xlate "get off :supporter", "leave :supporter"
xlate "get up from :supporter", "leave :supporter"
xlate "get up", :leave
xlate "stand", :leave
xlate "stand up", :leave
xlate "get off", :leave
xlate "get out :container", "leave :container"
xlate "get out of :container", "leave :container"
