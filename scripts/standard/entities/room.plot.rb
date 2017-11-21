class Room < Thing
  include ExplicitExits

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

def connect origin, destination, direction = nil, type: Portal, two_way: true
  if direction.nil?
    portal = make type, :parent => origin, :destination => destination
    if two_way == true
      portal2 = make type, :parent => destination, :destination => origin
    end
  else
    if direction.kind_of?(String)
      direction = Direction.find(direction)
    end
    portal = make type, :direction => direction, :parent => origin, :destination => destination
    portal.proper_named = true if type == Portal
    if two_way == true
      reverse = direction.reverse
      if reverse == nil
        raise "#{direction.name.cap_first} does not have an opposite direction"
      end
      portal2 = make type, :direction => reverse, :parent => destination, :destination => origin
      portal2.proper_named = true if type == Portal
    end
  end
  portal
end
