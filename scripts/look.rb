action :look do |actor|
	actor.tell actor.parent.longname.upcase
	actor.tell actor.parent.description
	actor.inject "itemize room"
end

action :look_around do |actor|
	actor.inject "look"
end

action :itemize_room do |actor|
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

action :look, query(:family) do |actor, thing|
	actor.tell thing.description
end

action :look, query(:parent) do |actor, thing|
	actor.inject "look"
end

action :look, String do |actor, string|
	actor.tell "You don't see any \"#{string}\" here."
end
