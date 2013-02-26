require "libx/murder"

declare "scripts/container.rb"
declare "scripts/carshuttle.rb"
declare "scripts/graphical.rb"
declare "scripts/speech.rb"
declare "scripts/conversation.rb"

module ::Gamefic
	class Car
		def default_image
			"car.png"
		end
		def default_map_command
			"drive"
		end
	end
end

load "opencases/locations/riverhead.rb"
load "opencases/locations/glenmont.rb"

action "^look_in_at".to_sym, query(:family, Container), subquery(:children, Murder::InstantLead) do |actor, container, lead|
	lead.suspect.know
	lead.suspect.locate
	passthru
end

action "^review".to_sym, query(:string) do |actor, string|
	actor.tell "You're not on a case right now."
end

action "review".to_sym, query(:string) do |actor, string|
	actor.tell "You're not on a case right now."
end

action "^review_case".to_sym do |actor|
	actor.tell "You're not on a case right now."
end

action "review_case".to_sym do |actor|
	actor.tell "You're not on a case right now."
end

action :episodes do |actor|
	puts "There are #{Series.instance.episodes.length} episodes"
end
