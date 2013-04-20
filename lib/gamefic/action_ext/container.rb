require "gamefic/entity_ext"

module Gamefic

	Action.new :look_inside, Query.new(:family, Container) do |actor, container|
		if container.children.length == 0
			actor.tell "You don't find anything."
		else
			actor.tell "#{container.longname} contains: #{container.children.join(', ')}"
		end
	end
	Syntax.new "look inside :container", :look_inside, :container
	Syntax.new "search :container", :look_inside, :container
	Syntax.new "look in :container", :look_inside, :container

	Action.new :look_in_at, Query.new(:family, Container), Subquery.new(:children, Entity) do |actor, container, item|
		actor.tell item.description
	end
	Syntax.new "look at :item in :container", :look_in_at, :container, :item
	Syntax.new "look :item in :container", :look_in_at, :container, :item

	Action.new :take_from, Query.new(:family, Container), Subquery.new(:children, Item) do |actor, container, item|
		item.parent = actor
		actor.tell "You take #{item.longname} from #{container.longname}."
	end
	Syntax.new "take :item from :container", :take_from, :container, :item
	Syntax.new "get :item from :container", :take_from, :container, :item
	Syntax.new "remove :item from :container", :take_from, :container, :item

	Action.new :drop_in, Query.new(:family, Container), Query.new(:children) do |actor, container, item|
		item.parent = container
		actor.tell "You put #{item.longname} in #{container.longname}."
	end
	Syntax.new "drop :item in :container", :drop_in, :container, :item
	Syntax.new "put :item in :container", :drop_in, :container, :item
	Syntax.new "place :item in :container", :drop_in, :container, :item

end
