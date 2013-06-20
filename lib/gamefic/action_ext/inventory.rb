require "gamefic/entity_ext"

module Gamefic

	Action.new Story.instance, :inventory do |actor|
		if actor.children.length > 0
			actor.tell actor.children.join(', ')
		else
			actor.tell "You aren't carrying anything."
		end
	end
	Syntax.new Story.instance, "i", :inventory

	Action.new Story.instance, :take, Query.new(:siblings, Portable) do |actor, thing|
		thing.parent = actor
		actor.tell "You take #{thing.longname}.", true
	end

	Action.new Story.instance, :take, Query.new(:siblings) do |actor, thing|
		actor.tell "You can't carry #{thing.longname}."
	end

	Action.new Story.instance, :take, String do |actor, thing|
		actor.tell "You don't see anything called \"#{thing}\" here."
	end

	Action.new Story.instance, :drop, Query.new(:children) do |actor, thing|
		thing.parent = actor.parent
		actor.tell "You drop #{thing.longname}.", true
	end

	Syntax.new Story.instance, "get :thing", :take, :thing
	Syntax.new Story.instance, "pick :thing up", :take, :thing
	Syntax.new Story.instance, "pick up :thing", :take, :thing

	Syntax.new Story.instance, "put down :thing", :drop, :thing
	Syntax.new Story.instance, "put :thing down", :drop, :thing

end
