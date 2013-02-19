action :go, query(:siblings, Portal) do |actor, portal|
	actor.parent = portal.destination
	actor.tell "You go #{portal.name}."
	actor.tell actor.parent.longname.upcase
	actor.perform "itemize room"
end

action :go, String do |actor, string|
	actor.tell "You don't see any exit \"#{string}\" from here."
end

action :go do |actor|
	actor.tell "Where do you want to go?"
end

instruct "north", :go, "north"
instruct "south", :go, "south"
instruct "west", :go, "west"
instruct "east", :go, "east"
instruct "up", :go, "up"
instruct "down", :go, "down"
instruct "northwest", :go, "northwest"
instruct "northeast", :go, "northeast"
instruct "southwest", :go, "southwest"
instruct "southeast", :go, "southeast"

instruct "n", :go, "north"
instruct "s", :go, "south"
instruct "w", :go, "west"
instruct "e", :go, "east"
instruct "u", :go, "up"
instruct "d", :go, "down"
instruct "nw", :go, "northwest"
instruct "ne", :go, "northeast"
instruct "sw", :go, "southwest"
instruct "se", :go, "southeast"
