# This query filters for objects that the player can see, regardless of
# whether they are reachable. It includes the following:
#
#   * Siblings (other entities with the same parent)
#   * The subject's children
#   * Children of the subject's room (if room is not parent)
#   * Entities on reachable supporters
#   * Entities inside reachable open containers
#   * Entities inside reachable transparent containers
#   * Entities attached to reachable entities

class Gamefic::Query::Visible < Gamefic::Query::Family
end

module Gamefic::Use
  def self.visible *args
    Gamefic::Query::Visible.new *args
  end
end
