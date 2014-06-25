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

class Query::Reachable < Query::Family
  def context_from(subject)
    array = super
    if subject.is?(:supported) or subject.is?(:contained)
      array.push subject.parent
    end
    array.each { |thing|
      if thing.kind_of?(Container)
        if thing.is? :open
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
    array.uniq
  end
end
