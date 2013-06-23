#require_relative "../entity_ext"

Action.new story, :inventory do |actor|
	if actor.children.length > 0
		actor.tell actor.children.join(', ')
	else
		actor.tell "You aren't carrying anything."
	end
end
Syntax.new story, "i", :inventory

Action.new story, :take, Query.new(:siblings, Portable) do |actor, thing|
	thing.parent = actor
	actor.tell "You take #{thing.longname}.", true
end

Action.new story, :take, Query.new(:siblings) do |actor, thing|
	actor.tell "You can't carry #{thing.longname}."
end

Action.new story, :take, String do |actor, thing|
	actor.tell "You don't see anything called \"#{thing}\" here."
end

Action.new story, :drop, Query.new(:children) do |actor, thing|
	thing.parent = actor.parent
	actor.tell "You drop #{thing.longname}.", true
end

Syntax.new story, "get :thing", :take, :thing
Syntax.new story, "pick :thing up", :take, :thing
Syntax.new story, "pick up :thing", :take, :thing

Syntax.new story, "put down :thing", :drop, :thing
Syntax.new story, "put :thing down", :drop, :thing
