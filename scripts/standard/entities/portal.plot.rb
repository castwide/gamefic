class Portal < Gamefic::Entity
  attr_accessor :destination
  serialize :destination, :direction

  # Find the portal in the destination that returns to this portal's parent
  #
  # @return [Room]
  def find_reverse
    return nil if destination.nil?
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
  
  # Get the ordinal direction of this Portal
  # Portals have distinct direction and name properties so games can display a
  # bare compass direction for exits, e.g., "south" vs. "the southern door."
  #
  # @return [Direction]
  def direction
    @direction
  end
  
  def direction= d
    @direction = Direction.find(d)
  end

  def name
    @name || (direction.nil? ? nil : direction.name)
  end
  
  def synonyms
    "#{super} #{@direction} #{!direction.nil? ? direction.synonyms : ''}"
  end
end
