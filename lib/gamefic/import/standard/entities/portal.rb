class Portal < Entity
  attr_accessor :destination, :direction
  def find_reverse
    #rev = Portal.reverse(self.direction)
    rev = direction.reverse
    if rev != nil
      destination.children.that_are(Portal).each { |c|
        if c.direction == rev
          return c
        end
      }
    end
    nil
  end
  # Portals have distinct direction and name properties so games can display a
  # bare compass direction for exits, e.g., "south" vs. "the southern door."
  def direction
    @direction || @name
  end
  def name
    @name || @direction.to_s
  end
  def synonyms
    "#{super} #{@direction} #{@direction.adjective} #{@direction.adverb}"
  end
end
