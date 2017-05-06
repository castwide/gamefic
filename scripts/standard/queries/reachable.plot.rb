# This query filters for objects that the player might be able to handle or
# manipulate, including the following:
#
#   * Siblings (other entities with the same parent)
#   * The subject's children
#   * Entities on reachable supporters
#   * Entities in reachable open containers
#   * Entities attached to reachable entities
#
# It excludes anything that may be visible but are not reachable:
#   * Entities inside closed transparent containers
#   * Entities that share the same room as the subject, but not the same parent.

class Gamefic::Query::Reachable < Gamefic::Query::Family
end

module Gamefic::Use
  def self.reachable *args
    Gamefic::Query::Reachable.new *args
  end  
end
