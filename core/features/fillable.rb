module Fillable

end

Action.new("drop", Context::CHILDREN, Context::ENVIRONMENT) { |object, container|
	if object.parent != actor
		actor.tell "You're not carrying it."
	else
		if container.kind_of? Fillable
			object.parent = container
			actor.tell "You put #{object.longname} in #{container.longname}."
		else
			actor.tell "You can't put #{object.longname} in #{container.longname}."
		end
	end
}
