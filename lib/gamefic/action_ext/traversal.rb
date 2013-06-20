require "gamefic/entity_ext"

module Gamefic

	Action.new Story.instance, :go, Query.new(:siblings, Portal) do |actor, portal|
		actor.parent = portal.destination
		actor.tell "You go #{portal.name}."
		actor.perform "itemize room"
	end

	Action.new Story.instance, :go, String do |actor, string|
		actor.tell "You don't see any exit \"#{string}\" from here."
	end

	Action.new Story.instance, :go do |actor|
		actor.tell "Where do you want to go?"
	end

	Syntax.new Story.instance, "north", :go, "north"
	Syntax.new Story.instance, "south", :go, "south"
	Syntax.new Story.instance, "west", :go, "west"
	Syntax.new Story.instance, "east", :go, "east"
	Syntax.new Story.instance, "up", :go, "up"
	Syntax.new Story.instance, "down", :go, "down"
	Syntax.new Story.instance, "northwest", :go, "northwest"
	Syntax.new Story.instance, "northeast", :go, "northeast"
	Syntax.new Story.instance, "southwest", :go, "southwest"
	Syntax.new Story.instance, "southeast", :go, "southeast"

	Syntax.new Story.instance, "n", :go, "north"
	Syntax.new Story.instance, "s", :go, "south"
	Syntax.new Story.instance, "w", :go, "west"
	Syntax.new Story.instance, "e", :go, "east"
	Syntax.new Story.instance, "u", :go, "up"
	Syntax.new Story.instance, "d", :go, "down"
	Syntax.new Story.instance, "nw", :go, "northwest"
	Syntax.new Story.instance, "ne", :go, "northeast"
	Syntax.new Story.instance, "sw", :go, "southwest"
	Syntax.new Story.instance, "se", :go, "southeast"

end
