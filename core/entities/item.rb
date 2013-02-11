class Item < Entity
	include Portable
end

Action.new("inventory") { |actor|
	actor.children.each { |c|
		actor.tell c.name
	}
}
