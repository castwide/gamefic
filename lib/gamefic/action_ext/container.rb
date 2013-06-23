Action.new story, :look_inside, Query.new(:family, Container) do |actor, container|
	if container.children.length == 0
		actor.tell "You don't find anything."
	else
		actor.tell "#{container.longname} contains: #{container.children.join(', ')}"
	end
end
Syntax.new story, "look inside :container", :look_inside, :container
Syntax.new story, "search :container", :look_inside, :container
Syntax.new story, "look in :container", :look_inside, :container

Action.new story, :look_in_at, Query.new(:family, Container), Subquery.new(:children, Entity) do |actor, container, item|
	actor.tell item.description
end
Syntax.new story, "look at :item in :container", :look_in_at, :container, :item
Syntax.new story, "look :item in :container", :look_in_at, :container, :item

Action.new story, :take_from, Query.new(:family, Container), Subquery.new(:children, Item) do |actor, container, item|
	item.parent = actor
	actor.tell "You take #{item.longname} from #{container.longname}."
end
Syntax.new story, "take :item from :container", :take_from, :container, :item
Syntax.new story, "get :item from :container", :take_from, :container, :item
Syntax.new story, "remove :item from :container", :take_from, :container, :item

Action.new story, :drop_in, Query.new(:family, Container), Query.new(:children) do |actor, container, item|
	item.parent = container
	actor.tell "You put #{item.longname} in #{container.longname}."
end
Syntax.new story, "drop :item in :container", :drop_in, :container, :item
Syntax.new story, "put :item in :container", :drop_in, :container, :item
Syntax.new story, "place :item in :container", :drop_in, :container, :item
