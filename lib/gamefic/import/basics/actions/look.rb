respond :look do |actor|
  actor.perform "look #{actor.parent.longname}"
end

respond :look_around do |actor|
  actor.perform "look @{actor.parent.longname}"
end

respond :look, Query.new(:parent) do |actor, room|
  actor.tell actor.parent.longname.cap_first
  actor.tell actor.parent.description
  chars = actor.parent.children.that_are(Character) - [actor]
  if chars.length > 0
    actor.tell "Others here: #{chars.join(", ")}"
  end
  items = actor.parent.children.that_are(Itemized)
  if items.length > 0
    actor.tell "Visible items: #{items.join(", ")}"
  end
  portals = actor.parent.children.that_are(Portal)
  if portals.length > 0
    actor.tell "Obvious exits: #{portals.join(', ')}"
  else
    actor.tell "Obvious exits: none"	
  end
end

respond :look, Query.new(:family) do |actor, thing|
  actor.tell thing.description
end

respond :look, String do |actor, string|
  containers = actor.children.that_are(Container)
  containers = containers + actor.parent.children.that_are(Container)
  found = false
  containers.each { |container|
    if container.closed? == false
      query = Query.new(:children, Portable)
      result = query.execute(container, string)
      if result.objects.length == 1
        found = true
        actor.tell "You look at #{result.objects[0].longname.specify} in #{container.longname.specify}."
        actor.perform "look #{result.objects[0].longname} in #{container.longname}"
        break
      end
    end
  }
  if found == false
    actor.tell "You don't see any \"#{string}\" here."
  end
end

xlate "look at :thing", :look, :thing
xlate "l", :look
xlate "l :thing", :look, :thing
xlate "examine :thing", :look, :thing
xlate "exam :thing", :look, :thing
xlate "x :thing", :look, :thing
