module Gamefic

	Action.new("look", Context::ENVIRONMENT) { |actor, object|
		actor.tell object.description
	}
	Action.new("look", Context::STRING) { |actor, string|
		actor.tell "I don't see any '#{string}' here."
	}
	Parser.translate("look at [thing]", "look [thing]")
	Parser.translate("examine [thing]", "look [thing]")

	Action.new("help") { |actor|
		actor.tell "The following commands are available: #{Parser.commands.join(', ')}"
	}

end
