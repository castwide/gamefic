Action.new story, :go, Query.new(:siblings, Portal) do |actor, portal|
	actor.parent = portal.destination
	actor.tell "You go #{portal.name}."
	actor.perform "itemize room"
end

Action.new story, :go, String do |actor, string|
	actor.tell "You don't see any exit \"#{string}\" from here."
end

Action.new story, :go do |actor|
	actor.tell "Where do you want to go?"
end

Syntax.new story, "north", :go, "north"
Syntax.new story, "south", :go, "south"
Syntax.new story, "west", :go, "west"
Syntax.new story, "east", :go, "east"
Syntax.new story, "up", :go, "up"
Syntax.new story, "down", :go, "down"
Syntax.new story, "northwest", :go, "northwest"
Syntax.new story, "northeast", :go, "northeast"
Syntax.new story, "southwest", :go, "southwest"
Syntax.new story, "southeast", :go, "southeast"

Syntax.new story, "n", :go, "north"
Syntax.new story, "s", :go, "south"
Syntax.new story, "w", :go, "west"
Syntax.new story, "e", :go, "east"
Syntax.new story, "u", :go, "up"
Syntax.new story, "d", :go, "down"
Syntax.new story, "nw", :go, "northwest"
Syntax.new story, "ne", :go, "northeast"
Syntax.new story, "sw", :go, "southwest"
Syntax.new story, "se", :go, "southeast"
