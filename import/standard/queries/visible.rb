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

module Gamefic::Query
  class Visible < Query::Family
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
        thing.children.that_are(:attached).each { |att|
          array.push att
          if att.kind_of?(Supporter) or att.is?(:open)
            array += att.children.that_are(:contained)
            array += att.children.that_are(:supported)
          end
        }
      }
      array
    end
  end
  def self.visible *args
    Visible.new *args
  end
end
