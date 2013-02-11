module Portable

end

Action.new("take", Context::ENVIRONMENT) { |actor, object|
	if object.parent == actor
		actor.tell "You're already carrying #{object.longname}."
	else
		if object.kind_of? Portable
			object.parent = actor
			actor.tell "You take #{object.longname}."
		else
			actor.tell "You can't carry #{object.longname}."
		end
	end
}

Action.new("drop", Context::CHILDREN) { |actor, object|
	if object.parent != actor
		actor.tell "You're not carrying it."
	else
		object.parent = actor.parent
		actor.tell "You drop #{object.longname}."
	end
}

Parser.translate "drop [object] floor", "drop [object]"
Parser.translate "drop [object] ground", "drop [object]"
