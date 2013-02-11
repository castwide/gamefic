# Implement cars and rooms designated as "waypoints" that players can use as driving destinations.

class Waypoint < Entity

end

class Car < Item
	def initialize
		super
		@portable = false
	end
end

class GpsConsole < Item
	def initialize
		super
		@portable = false
	end
end

Action.new("go", Car, nil, nil) { |actor, target, tool|
	actor.tell "You get in your car."
	actor.parent = target
}
Action.new("exit", nil, nil, Car) { |actor, target, tool|
	actor.tell "You get out of your car."
	actor.parent = actor.parent.parent
}
Action.new('go', String, nil, Car) { |actor, target, tool|
	act = Action.find('drive', target, tool, actor.parent)
	if (act)
		act.perform(actor, target, tool)
	end
}
Action.new('drive', String, nil, Car) { |actor, target, tool|
	destination = Entity.bind(target, Waypoint)
	if destination.is_a? Array
		locs = Array.new
		destination.each { |ent|
			if ent.kind_of? Waypoint
				locs.push(ent.name)
			end
		}
		if locs.length > 1
			actor.tell "'#{target.cap_first}' might refer to any of the following: #{locs.join(", ")}"
			destination = nil
		else
			destination = locs[0]
		end
	elsif destination != nil
		if destination.kind_of? Waypoint
			if actor.parent.parent == destination.parent
				actor.tell "You're already there."
			else
				actor.tell "You drive to #{destination.name}."
				actor.parent.parent = destination.parent
			end
		else
			actor.tell "I don't know any destination called #{target}."
		end
	else
		actor.tell "I don't know any destination called #{target}."
	end
}
Action.new('drive', nil, nil, Car) { |actor, target, tool|
	actor.tell "Where do you want to go?"
}
Action.new('use', GpsConsole, nil, Car) { |actor, target, tool|
	actor.tell "The following addresses are available:"
	locs = Entity.of_type(Waypoint)
	locs.each { |l|
		actor.tell l.longname.cap_first
	}
}
Action.new('look', GpsConsole, nil, Car) { |actor, target, tool|
	actor.tell target.description
	actor.perform('use gps')
}

Parser.add("get in {place}", "go {place}")
Parser.add("drive {place}", "drive {place} car")
Parser.add("drive to {place}", "drive {place} car")
Parser.add("get out", "exit car")
Parser.add("leave {something}", "exit {something}")
Parser.add("exit {something}", "exit {something}")
Parser.add("exit", "exit")
Parser.add("locations", "locations")
Parser.add("drive", "drive")
Parser.add("use {object}", "use {object}")
Parser.add("read {object}", "read {object}")
