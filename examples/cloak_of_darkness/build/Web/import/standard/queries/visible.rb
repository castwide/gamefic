require 'gamefic';module Gamefic;# This query filters for objects that the player can see, regardless of
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
  class Visible < Family
    def base_specificity
      40
    end
    def context_from(subject)
      array = super
      array += subject.room.children
      array.uniq!
      array.each { |thing|
        if thing.kind_of?(Container)
          if thing.open? or thing.transparent?
            array += thing.children.that_are_not(:attached?)
          end
        elsif thing.kind_of?(Supporter) or thing.kind_of?(Receptacle)
          array += thing.children.that_are_not(:attached?)
        end
        thing.children.that_are(:attached?).each { |att|
          array.push att
          if att.kind_of?(Supporter) or (att.kind_of?(Container) and (att.open? or att.transparent?))
            array += att.children.that_are_not(:attached?)
          end
        }
      }
      array - [subject]
    end
  end
end

module Gamefic::Use
  def self.visible *args
    Gamefic::Query::Visible.new *args
  end
end
;end
