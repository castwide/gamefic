class Item < Entity
	include Portable
end

Action.new("inventory") { |actor|
	if actor.children.length == 0
		actor.tell "You aren't carrying anything."
	else
		actor.children.each { |c|
			actor.tell c.name
		}
	end
}
