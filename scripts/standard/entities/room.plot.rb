class Room < Gamefic::Entity
  include Darkenable
  include ExplicitExits

  def connect(destination, direction = nil, type = Portal, two_way = true)
    if direction.kind_of?(Hash)
      connect2(destination, direction)
    else
      connect2 destination, direction: direction, type: type, two_way: true
    end
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
  
  private
  def connect2 destination, direction:nil, type:Portal, two_way:true
    if direction.nil?
      portal = type.new :parent => self, :destination => destination
      if two_way == true
        portal2 = type.new :parent => destination, :destination => self
      end
    else
      if direction.kind_of?(String)
        direction = Direction.find(direction)
      end
      portal = type.new :direction => direction, :parent => self, :destination => destination
      portal.proper_named = true if type == Portal
      if two_way == true
        reverse = direction.reverse
        if reverse == nil
          raise "#{direction.name.cap_first} does not have an opposite direction"
        end
        portal2 = type.new({
          :direction => reverse,
          :parent => destination,
          :destination => self
        })
        portal2.proper_named = true if type == Portal
      end
    end
    portal
  end
end
