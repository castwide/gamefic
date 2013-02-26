bus_depot = Waypoint.new :name => 'bus depot', :longname => 'Glenmont Bus Depot', :location => 'Glenmont', :parent => story

terminal = Room.new :name => 'terminal', :longname => 'bus terminal', :parent => story
terminal.connect bus_depot, "east"

hill_street = Room.new :name=> 'Hill Street', :parent => story
hill_street.connect bus_depot, "south"

hill_east = Room.new :name => 'East Hill Street', :parent => story
hill_east.connect hill_street, "west"

gun_range = Room.new :name => 'gun range', :longname => 'Glenmont Gun Range', :parent => story
gun_range.connect hill_east, "south"

gun_office = Room.new :name => 'office', :longname => "Jesse's office", :parent => story
gun_office.connect gun_range, "west"

jesse = Character.new :name => 'Jesse', :longname => 'Jesse Hudson', :parent => gun_office, :description => "Gruff but personable, Jesse is the owner of the Glenmont Gun Range. In addition to being an expert marksman, he learned ballistics during his career in law enforcement."

window = Scenery.new :name => 'window', :parent => gun_office
action :look, query(:siblings, window) do |actor, window|
	actor.tell "You see the gun range."
	if jesse.parent != gun_office
		actor.tell "Jesse is at the far end of the range, talking on his cell. If you have business with him, it looks like you'll have to wait a while."
	end
end

#jesse.on_update do |jesse|
#	if rand(180) == 1
#		if jesse.parent == gun_office
#			jesse.parent.tell "Jesse's cell phone rings. \"Hold on, I gotta take this.\" He steps out of the office.", true
#			gun_range.tell "Jesse walks out of his office with his phone to his ear. He wanders off toward the gun range."
#			jesse.parent = story
#		else
#			gun_range.tell "Jesse arrives from the gun range and walks into his office."
#			jesse.parent = gun_office
#			jesse.parent.tell "Jesse saunters into the office and sits at his desk with a sigh.", true
#		end
#	end
#end

action :show_to, query(:siblings, jesse), query(:children, Murder::Weapon) do |actor, jesse, weapon|
	actor.tell "+--"
	actor.tell "You show #{weapon.suspect.proper_name}'s gun to Jesse. \"Can you tell me if this gun matches the bullet we took out of #{weapon.story.victim.proper_name}?\""
	if weapon.suspect == weapon.story.killer
		actor.tell "Jesse analyzes it at his workbench. \"Yep,\" he says, \"this is the gun that killed #{weapon.story.victim.proper_name.last}, all right.\""
	else
		actor.tell "Jesse analyzes it at his workbench. \"No dice,\" he says. \"This ain't your murder weapon.\""
	end
	actor.tell "--+"
	weapon.analyze
end

action :show_to, query(:siblings, jesse), query(:children, Entity) do |actor, jesse, entity|
	actor.tell "Jesse has nothing to say about #{entity.longname}."
end
instruct "show [item] to [character]", :show_to, "[character] [item]"

action "^look".to_sym, query(:siblings, jesse) do |actor, jesse|
	x = {}
	x[:name] = jesse.longname
	x[:image] = jesse.image
	x[:class] = Character
	x[:description] = jesse.description
	x[:options] = Array.new
	actor.children.that_are(Murder::Clue).each { |child|
		opt = {}
		opt[:text] = "show #{child.longname}"
		opt[:command] = "show #{child.longname} to #{jesse.longname}"
		opt[:image] = ""
		x[:options].push opt
	}
	actor.tell "$ #{JSON.generate(x)}"
end

docks = Room.new :name => 'docks', :parent => story
docks.connect hill_east, "west"

hill_west = Room.new :name => 'West Hill Street', :parent => story
hill_west.connect hill_street, "east"

diablo = Room.new :name => 'Diablo Chicken', :parent => story
diablo.connect hill_west, "south"
