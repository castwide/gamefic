respond :leave, Query::Parent.new(Supporter) do |actor, supporter|
  actor.parent = supporter.parent
  actor.tell "You get off #{the supporter}."
end
respond :leave do |actor|
  if actor.is?(:supported)
    actor.perform "leave #{actor.parent}"
  else
    passthru
  end
end
xlate "exit :supporter", :leave, :supporter
xlate "get off :supporter", :leave, :supporter
xlate "get up from :supporter", :leave, :supporter
xlate "get up", :leave
xlate "stand", :leave
xlate "get off", :leave
