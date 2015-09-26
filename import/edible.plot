module Edibility
  attr_writer :edible
  def edible?
    @edible ||= false
  end
end

class Gamefic::Entity
  include Edibility
end

respond :eat, Query.reachable do |actor, item|
  actor.tell "You can't eat #{the item}."
end

respond :eat, Query.reachable(:edible?) do |actor, item|
  actor.tell "You eat #{the item}."
  item.destroy
end
