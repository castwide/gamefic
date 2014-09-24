import 'edible'

options(Item, :not_edible, :edible)

respond :eat, Query::Reachable.new(:not_edible) do |actor, item|
  actor.tell "You can't eat #{the item}."
end

respond :eat, Query::Reachable.new(:edible) do |actor, item|
  actor.tell "You eat #{the item}."
  item.destroy
end
