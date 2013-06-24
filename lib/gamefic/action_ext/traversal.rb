module Gamefic

	Action.new nil, :go, Query.new(:siblings, Portal) do |actor, portal|
		actor.parent = portal.destination
		actor.tell "You go #{portal.name}."
		actor.perform "itemize room"
	end

	Action.new nil, :go, String do |actor, string|
		actor.tell "You don't see any exit \"#{string}\" from here."
	end

	Action.new nil, :go do |actor|
		actor.tell "Where do you want to go?"
	end

	Syntax.new nil, "north", :go, "north"
	Syntax.new nil, "south", :go, "south"
	Syntax.new nil, "west", :go, "west"
	Syntax.new nil, "east", :go, "east"
	Syntax.new nil, "up", :go, "up"
	Syntax.new nil, "down", :go, "down"
	Syntax.new nil, "northwest", :go, "northwest"
	Syntax.new nil, "northeast", :go, "northeast"
	Syntax.new nil, "southwest", :go, "southwest"
	Syntax.new nil, "southeast", :go, "southeast"

	Syntax.new nil, "n", :go, "north"
	Syntax.new nil, "s", :go, "south"
	Syntax.new nil, "w", :go, "west"
	Syntax.new nil, "e", :go, "east"
	Syntax.new nil, "u", :go, "up"
	Syntax.new nil, "d", :go, "down"
	Syntax.new nil, "nw", :go, "northwest"
	Syntax.new nil, "ne", :go, "northeast"
	Syntax.new nil, "sw", :go, "southwest"
	Syntax.new nil, "se", :go, "southeast"

end
