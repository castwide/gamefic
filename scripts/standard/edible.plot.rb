module Edibility
  attr_writer :edible
  def edible?
    @edible ||= false
  end
end

class Thing
  include Edibility
end

respond :eat, Use.available do |actor, item|
  actor.tell "You can't eat #{the item}."
end

respond :eat, Use.available(:edible?) do |actor, item|
  actor.tell "You eat #{the item}."
  destroy item
end
