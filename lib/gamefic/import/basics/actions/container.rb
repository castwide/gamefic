respond :look, Query.new(:family, Container) do |actor, thing|
  passthru
  if thing.closeable?
    actor.tell "#{thing.longname.specify.cap_first} is #{thing.closed? ? 'closed' : 'open'}."
  end
end

respond :look_inside, Query.new(:family, Container) do |actor, container|
  if container.closed?
    actor.tell "#{container.longname.cap_first.specify} is closed."
  else
    if container.children.length == 0
      actor.tell "You don't find anything."
    else
      if container.children.length == 1
        actor.tell "#{container.longname.specify.cap_first} contains #{container.children[0].longname}."
      else
        actor.tell "#{container.longname.specify.cap_first} contains: #{container.children.join_and(', ')}."
      end
    end
  end
end
xlate "look inside :container", :look_inside, :container
xlate "search :container", :look_inside, :container
xlate "look in :container", :look_inside, :container

respond :look_in_at, Query.new(:family, Container), Subquery.new(:children, Entity) do |actor, container, item|
  if container.closed?
    actor.tell "#{container.longname.cap_first.specify} is closed."
  else
    actor.tell item.description
  end
end

respond :look_in_at, Query.new(:family, Container), Query.new(:string) do |actor, container, item|
  if container.closed?
    actor.tell "#{container.longname.cap_first.specify} is closed."
  else
    passthru
  end
end

xlate "look at :item in :container", :look_in_at, :container, :item
xlate "look :item in :container", :look_in_at, :container, :item

respond :take_from, Query.new(:family, Container), Subquery.new(:children, Portable) do |actor, container, item|
  if container.closed?
    actor.tell "#{container.longname.cap_first.specify} is closed."
  else
    item.parent = actor
    actor.tell "You take #{item.longname} from #{container.longname.specify}."
  end
end
xlate "take :item from :container", :take_from, :container, :item
xlate "get :item from :container", :take_from, :container, :item
xlate "remove :item from :container", :take_from, :container, :item

respond :drop_in, Query.new(:family, Container), Query.new(:children) do |actor, container, item|
  if container.closed?
    actor.tell "#{container.longname.cap_first.specify} is closed."
  else
    item.parent = container
    actor.tell "You put #{item.longname} in #{container.longname}."
  end
end
xlate "drop :item in :container", :drop_in, :container, :item
xlate "put :item in :container", :drop_in, :container, :item
xlate "place :item in :container", :drop_in, :container, :item

respond :open, Query.new(:string) do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :open, Query.new(:family, Entity) do |actor, thing|
  actor.tell "You can't open #{thing.longname.specify}."
end

respond :open, Query.new(:family, Container) do |actor, container|
  if container.closeable?
    if container.closed?
      actor.tell "You open #{container.longname.specify}."
      container.closed = false
      actor.perform "look inside #{container.longname}"
    else
      actor.tell "It's already open."
    end
  else
    actor.tell "You can't open #{container.longname.specify}."
  end
end

respond :close, Query.new(:string) do |actor, string|
  actor.tell "You don't see any \"#{string}\" here."
end

respond :close, Query.new(:family, Entity) do |actor, thing|
  actor.tell "You can't close #{thing.longname.specify}."
end

respond :close, Query.new(:family, Container) do |actor, container|
  if container.closeable?
    if container.closed?
      actor.tell "It's already closed."
    else
      actor.tell "You close #{container.longname.specify}."
      container.closed = true
    end
  else
    actor.tell "You can't close #{container.longname.specify}."
  end  
end
