class Portal < Entity
	attr_writer :destination
	def initialize
		super
		@destination = nil
	end
	def self.reverse(direction)
		case direction.downcase
			when "north"
				"south"
			when "south"
				"north"
			when "west"
				"east"
			when "east"
				"west"
			when "northwest"
				"southeast"
			when "southeast"
				"northwest"
			when "northeast"
				"southwest"
			when "southwest"
				"northeast"
			when "up"
				"down"
			when "down"
				"up"
			else
				"unknown_direction"
		end
	end
	def destination
		@destination
	end
end

class Context
	PORTAL = Context.new("exit", [[:parent, :children], Portal])
end

Action.new("go", Context::PORTAL) { |actor, portal|
	actor.parent = portal.destination
	actor.tell "You go #{portal.name}."
	actor.perform "look around"
}

Action.new("go", Context::STRING) { |actor, unknown|
	actor.tell "I don't see an exit '#{unknown}' from here."
}

Action.new("exit") { |actor|
	portals = actor.parent.children.that_are(Portal)
	if portals.length > 1
		actor.tell "Which direction: #{portals.join(', ')}?"
	elsif portals.length == 1
		actor.parent = portals[0].destination
		actor.tell "You go #{portals[0].name}."
		actor.tell "\n#{actor.parent.longname.upcase}"
		actor.perform "look around"
	else
		actor.tell "You don't see any exit."
	end
}

Parser.translate("out", "exit")

Parser.translate("north", "go north")
Parser.translate("south", "go south")
Parser.translate("west", "go west")
Parser.translate("east", "go east")
Parser.translate("northwest", "go northwest")
Parser.translate("northeast", "go northeast")
Parser.translate("southwest", "go southwest")
Parser.translate("southeast", "go southeast")
Parser.translate("up", "go up")
Parser.translate("down", "go down")

Parser.translate("n", "go north")
Parser.translate("s", "go south")
Parser.translate("w", "go west")
Parser.translate("e", "go east")
Parser.translate("nw", "go northwest")
Parser.translate("ne", "go northeast")
Parser.translate("sw", "go southwest")
Parser.translate("se", "go southeast")
Parser.translate("u", "go up")
Parser.translate("d", "go down")
