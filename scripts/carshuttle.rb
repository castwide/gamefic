require "libx/carshuttle.rb"

action :drive, query(:parent, Car), String do |actor, string|
	actor.tell "Where do you want to go?"
	passthru
end

action :drive, query(:parent, Car) do |actor, car|
	actor.tell "Available destinations:"
	actor.root.children.that_are(Waypoint).each { |waypoint|
		actor.tell "#{waypoint.location}"
	}
end

action :drive, query(:parent, Car), query(:root, Waypoint) do |actor, car, waypoint|
	if actor.parent.parent != waypoint
		actor.parent.parent = waypoint
		actor.tell "You drive to #{waypoint.location}."
	else
		actor.tell "You're already there."
	end
end

action :enter, query(:siblings, Car) do |actor, car|
	actor.parent = car
	actor.tell "You get in #{car.longname}."
end

action :exit, query(:parent, Car) do |actor, car|
	actor.parent = car.parent
	actor.tell "You get out of #{car.longname}."
	actor.tell actor.parent.longname.upcase
	actor.perform "itemize room"
end

instruct("drive", :drive, "car")
instruct("drive [place]", :drive, "car [place]")
instruct("drive to [place]", :drive, "car [place]")
instruct("go to [place]", :drive, "car [place]")
instruct("drive [car] to [place]", :drive, "[car] [place]")

instruct("get out [place]", :exit, "[place]")
instruct("get out", :exit, "car")
instruct("get in [place]", :enter, "[place]")
instruct("exit", :exit, "car")
instruct("out", :exit, "car")
