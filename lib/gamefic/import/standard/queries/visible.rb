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

class Query::Visible < Query::Family
  def base_specificity
    40
  end
  def context_from(subject)
    array = super
    array += subject.room.children
    array.uniq!
    array.each { |thing|
      if thing.kind_of?(Container)
        if thing.is? :open or thing.is? :transparent
          array += thing.children.that_are(:contained)
        end
      elsif thing.kind_of?(Supporter)
        array += thing.children.that_are(:supported)
      end
      array += thing.children.that_are(:attached)
    }
    array
  end
end
