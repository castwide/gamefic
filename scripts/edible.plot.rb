module Edibility
  attr_writer :edible
  def edible?
    @edible ||= false
  end
end

class Gamefic::Entity
  include Edibility
end

respond :eat, Use.reachable do |actor, item|
  actor.tell "You can't eat #{the item}."
end

respond :eat, Use.reachable(:edible?) do |actor, item|
  actor.tell "You eat #{the item}."
  destroy item
end
