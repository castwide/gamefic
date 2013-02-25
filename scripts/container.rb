require "lib/entities/item"
declare "scripts/inventory.rb"
require "lib/entities/container"

action :look_inside, query(:family, Container) do |actor, container|
	if container.children.length == 0
		actor.tell "You don't find anything."
	else
		actor.tell "#{container.longname} contains: #{container.children.join(', ')}"
	end
end
instruct "look inside [container]", :look_inside, "[container]"
instruct "search [container]", :look_inside, "[container]"
instruct "look in [container]", :look_inside, "[container]"

action :look_in_at, query(:family, Container), subquery(:children, Entity) do |actor, container, item|
	actor.tell item.description
end
instruct "look at [item] in [container]", :look_in_at, "[container] [item]"
instruct "look [item] in [container]", :look_in_at, "[container] [item]"

action :take_from, query(:family, Container), subquery(:children, Portable) do |actor, container, item|
	item.parent = actor
	actor.tell "You take #{item.longname} from #{container.longname}."
end
instruct "take [item] from [container]", :take_from, "[container] [item]"
instruct "get [item] from [container]", :take_from, "[container] [item]"
instruct "remove [item] from [container]", :take_from, "[container] [item]"

action :drop_in, query(:family, Container), query(:children) do |actor, container, item|
	item.parent = container
	actor.tell "You put #{item.longname} in #{container.longname}."
end
instruct "drop [item] in [container]", :drop_in, "[container] [item]"
instruct "put [item] in [container]", :drop_in, "[container] [item]"
instruct "place [item] in [container]", :drop_in, "[container] [item]"
