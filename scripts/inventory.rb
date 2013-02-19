action :inventory do |actor|
	if actor.children.length > 0
		actor.tell actor.children.join(', ')
	else
		actor.tell "You aren't carrying anything."
	end
end

action :take, query(:siblings, Portable) do |actor, thing|
	thing.parent = actor
	actor.tell "You take #{thing.longname}."
end

action :take, query(:siblings) do |actor, thing|
	actor.tell "You can't carry #{thing.longname}."
end

action :take, String do |actor, thing|
	actor.tell "You don't see anything called \"#{thing}\" here."
end

action :drop, query(:children) do |actor, thing|
	thing.parent = actor.parent
	actor.tell "You drop #{thing.longname}."
end

instruct "get [thing]", :take, "[thing]"
instruct "pick [thing] up", :take, "[thing]"
instruct "pick up [thing]", :take, "[thing]"

instruct "put down [thing]", :drop, "[thing]"
instruct "put [thing] down", :drop, "[thing]"
