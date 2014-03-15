module Gamefic

	Action.new nil, :look_inside, Query.new(:family, Container) do |actor, container|
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
	Syntax.new nil, "look inside :container", :look_inside, :container
	Syntax.new nil, "search :container", :look_inside, :container
	Syntax.new nil, "look in :container", :look_inside, :container

	Action.new nil, :look_in_at, Query.new(:family, Container), Subquery.new(:children, Entity) do |actor, container, item|
    if container.closed?
      actor.tell "#{container.longname.cap_first.specify} is closed."
    else
      actor.tell item.description
    end
	end
  
  Action.new nil, :look_in_at, Query.new(:family, Container), Query.new(:string) do |actor, container, item|
    if container.closed?
      actor.tell "#{container.longname.cap_first.specify} is closed."
    else
      passthru
    end
  end
  
	Syntax.new nil, "look at :item in :container", :look_in_at, :container, :item
	Syntax.new nil, "look :item in :container", :look_in_at, :container, :item

	Action.new nil, :take_from, Query.new(:family, Container), Subquery.new(:children, Portable) do |actor, container, item|
    if container.closed?
      actor.tell "#{container.longname.cap_first.specify} is closed."
    else
      item.parent = actor
      actor.tell "You take #{item.longname} from #{container.longname}."
    end
	end
	Syntax.new nil, "take :item from :container", :take_from, :container, :item
	Syntax.new nil, "get :item from :container", :take_from, :container, :item
	Syntax.new nil, "remove :item from :container", :take_from, :container, :item

	Action.new nil, :drop_in, Query.new(:family, Container), Query.new(:children) do |actor, container, item|
    if container.closed?
      actor.tell "#{container.longname.cap_first.specify} is closed."
    else
      item.parent = container
      actor.tell "You put #{item.longname} in #{container.longname}."
    end
	end
	Syntax.new nil, "drop :item in :container", :drop_in, :container, :item
	Syntax.new nil, "put :item in :container", :drop_in, :container, :item
	Syntax.new nil, "place :item in :container", :drop_in, :container, :item
  
  Action.new nil, :open, Query.new(:family, Container) do |actor, container|
    if container.closeable?
      if container.closed?
        actor.tell "You open #{container.longname.specify}."
        container.closed = false
      else
        actor.tell "It's already open."
      end
    else
      actor.tell "You can't open #{container.longname.specify}."
    end
  end
  
  Action.new nil, :close, Query.new(:family, Container) do |actor, container|
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
  
end
