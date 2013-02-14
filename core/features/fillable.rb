module Gamefic

	module Fillable

	end

	#Action.new("drop_in", Context::ENVIRONMENT.reduce(Fillable), Context::INVENTORY) { |actor, container, object|
	#	if object.parent != actor
	#		actor.tell "You're not carrying it."
	#	else
	#		if container.kind_of? Fillable
	#			object.parent = container
	#			actor.tell "You put #{object.longname} in #{container.longname}."
	#		else
	#			actor.tell "You can't put #{object.longname} in #{container.longname}."
	#		end
	#	end
	#}

	#Parser.translate("drop [object] in [container]", "drop_in [container] [object]")
	#Parser.translate("put [object] in [container]", "drop_in [container] [object]")

	#Action.new("take_from", Context::ENVIRONMENT.reduce(Fillable), Context::STRING) { |actor, container, object|
	#	matches = container.children.matching(object)
	#	if matches.length > 1
	#		actor.tell "That could be a lot of things."
	#	elsif matches.length == 1
	#		matches[0].parent = actor
	#		actor.tell "You take #{matches[0].longname} from #{container.longname}."
	#	else
	#		actor.tell "You don't see any #{object} in #{container.longname}."
	#	end
	#}

	#Parser.translate("take [object] from [container]", "take_from [container] [object]")
	#Parser.translate("get [object] from [container]", "take_from [container] [object]")

	#Action.new("look", Context::ENVIRONMENT.reduce(Fillable)) { |actor, container|
	#	actor.tell container.description
	#	if container.children.length > 0
	#		actor.tell "#{container.longname} contains: #{container.children.join(', ')}"
	#	end
	#}

end
