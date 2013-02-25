action :look do |actor|
	actor.inject "itemize room full"
end

action :look_around do |actor|
	actor.inject "look"
end

action :itemize_room, query(:string) do |actor, option|
	actor.tell "@ #{actor.parent.longname.cap_first}"
	if option == "full"
		actor.tell actor.parent.description
	end
	chars = actor.parent.children.that_are(Character) - [actor]
	if chars.length > 0
		actor.tell "Others here: #{chars.join(", ")}"
	end
	#items = actor.parent.children.that_are(Itemized) - [chars] - [actor] - actor.parent.children.that_are(Portal)
	items = actor.parent.children.that_are(Itemized)
	if items.length > 0
		actor.tell "Visible items: #{items.join(", ")}"
	end
	portals = actor.parent.children.that_are(Portal)
	if portals.length > 0
		actor.tell "Obvious exits: #{portals.join(', ')}"
	else
		actor.tell "Obvious exits: none"	
	end
end
instruct "itemize room", :itemize_room, "short"

action :look, query(:family) do |actor, thing|
	actor.tell thing.description
end

action :look, query(:parent) do |actor, thing|
	actor.inject "look"
end

action :look, String do |actor, string|
	actor.tell "You don't see any \"#{string}\" here."
end

instruct "look at [thing]", :look, "[thing]"
