module Gamefic

	class Car < Entity
		include Itemized
	end

	class Waypoint < Room
		attr_writer :location
		def location
			@location.to_s != '' ? @location : longname
		end
		def keywords
			"#{super} #{location}"
		end
	end

	Action.new("drive", Context::PARENT.reduce(Car), Context::ANYWHERE.reduce(Waypoint)) { |actor, car, waypoint|
		actor.parent.parent = waypoint
		actor.tell "You drive to #{waypoint.location}."
	}

	Action.new("drive", Context::PARENT.reduce(Car), Context::STRING) { |actor, string|
		actor.tell "Where do you want to go?"
		passthru
	}

	Action.new("drive", Context::PARENT.reduce(Car)) { |actor, car|
		actor.tell "Available destinations:"
		Entity.array.that_are(Waypoint).each { |waypoint|
			actor.tell "#{waypoint.location}"
		}
	}

	Action.new("enter", Context::PROXIMATE.reduce(Car)) { |actor, car|
		actor.parent = car
		actor.tell "You get in #{car.longname}."
	}

	Action.new("exit", Context::PARENT.reduce(Car)) { |actor, car|
		actor.parent = car.parent
		actor.tell "You get out of #{car.longname}."
		actor.tell actor.parent.longname.upcase
		actor.perform "itemize room"
	}

	Parser.translate("drive", "drive car")
	Parser.translate("drive to [place]", "drive car [place]")
	Parser.translate("go to [place]", "drive car [place]")

	Parser.translate("get out [place]", "exit [place]")
	Parser.translate("get out", "exit car")
	Parser.translate("get in [place]", "enter [place]")
	Parser.translate("exit", "exit car")
	Parser.translate("out", "exit car")

end
