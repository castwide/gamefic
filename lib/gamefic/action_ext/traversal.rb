require "gamefic/entity_ext"

module Gamefic

	Action.new :go, Query.new(:siblings, Portal) do |actor, portal|
		actor.parent = portal.destination
		actor.tell "You go #{portal.name}."
		actor.perform "itemize room"
	end

	Action.new :go, String do |actor, string|
		actor.tell "You don't see any exit \"#{string}\" from here."
	end

	Action.new :go do |actor|
		actor.tell "Where do you want to go?"
	end

	Syntax.new "north", :go, "north"
	Syntax.new "south", :go, "south"
	Syntax.new "west", :go, "west"
	Syntax.new "east", :go, "east"
	Syntax.new "up", :go, "up"
	Syntax.new "down", :go, "down"
	Syntax.new "northwest", :go, "northwest"
	Syntax.new "northeast", :go, "northeast"
	Syntax.new "southwest", :go, "southwest"
	Syntax.new "southeast", :go, "southeast"

	Syntax.new "n", :go, "north"
	Syntax.new "s", :go, "south"
	Syntax.new "w", :go, "west"
	Syntax.new "e", :go, "east"
	Syntax.new "u", :go, "up"
	Syntax.new "d", :go, "down"
	Syntax.new "nw", :go, "northwest"
	Syntax.new "ne", :go, "northeast"
	Syntax.new "sw", :go, "southwest"
	Syntax.new "se", :go, "southeast"

end
