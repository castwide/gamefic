#require_relative "../entity_ext"

Action.new nil, :inventory do |actor|
	if actor.children.length > 0
		actor.tell actor.children.join(', ')
	else
		actor.tell "You aren't carrying anything."
	end
end
Syntax.new nil, "i", :inventory

Action.new nil, :take, Query.new(:siblings, Portable) do |actor, thing|
	thing.parent = actor
	actor.tell "You take #{thing.longname}.", true
end

Action.new nil, :take, Query.new(:siblings) do |actor, thing|
	actor.tell "You can't carry #{thing.longname}."
end

Action.new nil, :take, String do |actor, thing|
	actor.tell "You don't see anything called \"#{thing}\" here."
end

Action.new nil, :drop, Query.new(:children) do |actor, thing|
	thing.parent = actor.parent
	actor.tell "You drop #{thing.longname}.", true
end

Syntax.new nil, "get :thing", :take, :thing
Syntax.new nil, "pick :thing up", :take, :thing
Syntax.new nil, "pick up :thing", :take, :thing

Syntax.new nil, "put down :thing", :drop, :thing
Syntax.new nil, "put :thing down", :drop, :thing
