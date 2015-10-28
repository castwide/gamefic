require 'gamefic';module Gamefic;# This query filters for objects that the player might be able to handle or
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

module Gamefic::Query
  class Reachable < Family
    def context_from(subject)
      array = super
      if subject.parent.kind_of?(Container) || subject.parent.kind_of?(Supporter)
        array.push subject.parent
      end
      if subject.parent != subject.room
        array += subject.room.children
      end
      array.each { |thing|
        if thing.kind_of?(Container)
          if thing.open?
            array += thing.children.that_are_not(:attached?)
          end
        elsif thing.kind_of?(Supporter) or thing.kind_of?(Receptacle) or thing == subject
          array += thing.children.that_are_not(:attached?)
        end
        thing.children.that_are(:attached?).each { |att|
          array.push att
          if att.kind_of?(Supporter) or (att.kind_of?(Container) and att.open?)
            array += att.children
          end
        }
      }
      array.uniq - [subject]
    end
  end
end

module Gamefic::Use
  def self.reachable *args
    Gamefic::Query::Reachable.new *args
  end  
end
;end
