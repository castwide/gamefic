class Room < Entity
  def connect(destination, direction, type = Portal, two_way = true)
    portal = type.new self.plot, :name => direction, :parent => self, :destination => destination
    portal.proper_named = true
    if two_way == true
      reverse = Portal.reverse(direction)
      if reverse == nil
        raise "\"#{direction.cap_first}\" does not have an opposite direction"
      end
      portal2 = type.new(self.plot, {
        :name => reverse,
        :parent => destination,
        :destination => self
      })
      portal2.proper_named = true
    end
    portal
  end
  def synonyms
    super.to_s + " around here room"
  end
  def tell(message, refresh = false)
    children.each { |c|
      c.tell message, refresh
    }
  end
end

options(Room, :lighted, :dark).default = :lighted
options(Room, :enterable).default = :enterable
