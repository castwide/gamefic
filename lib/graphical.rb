game.actions.add Action.new("__type", Entity, nil) { |actor, target, tool|
	class_list = Array.new
	cur = target.class
	while (cur != Object)
		class_list.push cur
		cur = cur.superclass
	end
	actor.tell class_list.join('<')
}

game.actions.add Action.new("__hint", Container, nil) { |actor, target, tool|
	hint_list = ['look','take']
	if (target.opened? == true)
		hint_list.push('search')
		hint_list.push('close')
	else
		hint_list.push('open')
	end
	actor.tell hint_list.join(',')
}

game.actions.add Action.new("__hint", Entity, nil) { |actor, target, tool|
	actor.tell("look,take")
}
game.actions.add Action.new("__hint", Portal, nil) { |actor, target, tool|
	actor.tell("go")
}
game.actions.add Action.new("__hint", Door, nil) { |actor, target, tool|
	actor.tell("go,open,close")
}

game.parser.add("__type {object}", "__type {object}")
game.parser.add("__hint {object}", "__hint {object}")
