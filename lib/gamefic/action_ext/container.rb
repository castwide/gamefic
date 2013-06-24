module Gamefic

	Action.new nil, :look_inside, Query.new(:family, Container) do |actor, container|
		if container.children.length == 0
			actor.tell "You don't find anything."
		else
			actor.tell "#{container.longname} contains: #{container.children.join(', ')}"
		end
	end
	Syntax.new nil, "look inside :container", :look_inside, :container
	Syntax.new nil, "search :container", :look_inside, :container
	Syntax.new nil, "look in :container", :look_inside, :container

	Action.new nil, :look_in_at, Query.new(:family, Container), Subquery.new(:children, Entity) do |actor, container, item|
		actor.tell item.description
	end
	Syntax.new nil, "look at :item in :container", :look_in_at, :container, :item
	Syntax.new nil, "look :item in :container", :look_in_at, :container, :item

	Action.new nil, :take_from, Query.new(:family, Container), Subquery.new(:children, Item) do |actor, container, item|
		item.parent = actor
		actor.tell "You take #{item.longname} from #{container.longname}."
	end
	Syntax.new nil, "take :item from :container", :take_from, :container, :item
	Syntax.new nil, "get :item from :container", :take_from, :container, :item
	Syntax.new nil, "remove :item from :container", :take_from, :container, :item

	Action.new nil, :drop_in, Query.new(:family, Container), Query.new(:children) do |actor, container, item|
		item.parent = container
		actor.tell "You put #{item.longname} in #{container.longname}."
	end
	Syntax.new nil, "drop :item in :container", :drop_in, :container, :item
	Syntax.new nil, "put :item in :container", :drop_in, :container, :item
	Syntax.new nil, "place :item in :container", :drop_in, :container, :item

end
