action :inventory do |actor|
	if actor.children.length > 0
		actor.tell actor.children.join(', ')
	else
		actor.tell "You aren't carrying anything."
	end
end

action :take, query(:parent, Portable) do |actor, thing|
	thing.parent = actor
	actor.tell "You take #{thing.longname}."
end

action :drop, query(:self) do |actor, thing|
	thing.parent = actor.parent
	actor.tell "You drop #{thing.longname}."
end
