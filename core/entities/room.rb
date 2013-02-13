require "core/entities/portal.rb"

module Gamefic

	class Room < Entity
		def connect(destination, direction, type = Portal, two_way = true)
			portal = type.create(
				:name => direction,
				:parent => self,
				:destination => destination
			)
			if two_way == true
				portal = type.create(
					:name => Portal.reverse(direction),
					:parent => destination,
					:destination => self
				)
			end
			self
		end
	end

	Action.new("look_around") { |actor|
		actor.tell actor.parent.longname.upcase
		actor.tell actor.parent.description
		actor.perform "itemize room"
	}

	Action.new("itemize_room") { |actor|
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
	}

	Parser.translate("look", "look_around")

end
