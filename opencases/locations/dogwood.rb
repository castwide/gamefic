require "libx/citizen.rb"

declare "scripts/look.rb"
declare "scripts/traversal.rb"

zone = Zone.new
zone.parent = story

high = Room.new :parent => zone, :name => 'High Street'
main = Room.new :parent => zone, :name => 'Main Street'
main.connect high, "east"
park = Room.new :parent => zone, :name => 'park'
park.connect high, "west"
post = Room.new :parent => zone, :name => 'Post Office'
post.connect main, "south"

rooms = zone.flatten.that_are(Room)
Citizen.new :parent => zone.flatten.that_are(Room).random
Citizen.new :parent => zone.flatten.that_are(Room).random

on_update do
	if zone.flatten.that_are(Citizen).length < 5 and rand(60) == 1
		rooms = zone.flatten.that_are(Room)
		Citizen.new :parent => rooms.random
	end
	if rand(120) == 1
		citizens = zone.flatten.that_are(Citizen).that_are_not(Fugitive)
		if citizens.length > 0
			r = citizens.random
			if r.parent.children.that_are(Player).length == 0
				r.destroy
			end
		end
	end
	if zone.flatten.that_are(Fugitive).length == 0 and rand(30) == 1
		rooms = zone.flatten.that_are(Room)
		fugitive = Fugitive.new :parent => rooms.random
		poster = Fixture.new :name => 'wanted poster', :parent => post, :description => "Police are looking for #{fugitive.proper_name}, a #{fugitive.physical_description}."
		post.tell "A postal clerk hangs a wanted poster on the wall.", true
	end
	zone.flatten.that_are(Character).each { |c|
		if c.session[:suspension].to_i > 0
			c.session[:suspension] = c.session[:suspension] - 1
			if c.session[:suspension] == 0
				c.tell "You're off suspension."
			end
		end
	}
end

action :arrest, query(:string) do |actor, string|
	if actor.session[:suspension].to_i > 0
		minutes = (actor.session[:suspension].to_f / 60.0).ceil
		actor.tell "You're under suspension for #{minutes} more minute#{minutes > 1 ? 's' : ''}."
	else
		keywords = Keywords.new(string)
		caught = false
		actor.parent.children.that_are(Fugitive).each { |f|
			match = keywords.found_in(Keywords.new(f.proper_name))
			if match > 0
				actor.tell "Good job!"
				actor.session[:bad_arrests] = 0
				f.parent = nil
				post.children.that_are(Fixture)[0].parent = nil
				caught = true
				break
			end
		}
		if caught == false
			actor.tell "You need to know the fugitive's name to make an arrest (\"#{string}\" doesn't match anyone here)."
			actor.session[:bad_arrests] = actor.session[:bad_arrests].to_i + 1
			if actor.session[:bad_arrests] > 2
				actor.session[:bad_arrests] = 0
				actor.session[:suspension] = 180
				actor.tell "Your arrest power has been suspended for 3 minutes due to too many false alarms."
			end
		end
	end
end

introduction do |player|
	player.parent = park
end
