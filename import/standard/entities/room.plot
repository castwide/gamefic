class Gamefic::Room < Entity
  def connect(destination, direction, type = Portal, two_way = true)
    if direction.kind_of?(String)
      direction = Direction.find(direction)
    end
    portal = type.new self.plot, :direction => direction, :parent => self, :destination => destination
    portal.proper_named = true if type == Portal
    if two_way == true
      reverse = direction.reverse
      if reverse == nil
        raise "#{direction.name.cap_first} does not have an opposite direction"
      end
      portal2 = type.new(self.plot, {
        :direction => reverse,
        :parent => destination,
        :destination => self
      })
      portal2.proper_named = true if type == Portal
    end
    portal
  end
  def synonyms
    @synonyms.to_s + " around here room"
  end
  def tell(message)
    children.each { |c|
      c.tell message
    }
  end
  def find_portal(direction)
    d = direction.to_s
    portals = children.that_are(Portal).delete_if { |p| p.direction.to_s != d }
    portals[0]
  end
end

options(Room, :lighted, :dark)
options(Room, :enterable, :not_enterable)
options(Room, :explicit_with_exits, :not_explicit_with_exits)
