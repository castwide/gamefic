# @!method connect destination, direction = nil, type: Portal, two_way: true
#   Create a portal to connect this room to a destination.
#   @return [Portal]
class Room < Thing
  attr_writer :explicit_exits

  set_default explicit_exits: true

  def explicit_exits?
    @explicit_exits = self.class.default_attribute[:explicit_exits] if @explicit_exits.nil?
    @explicit_exits
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

  def self.explicit_exits?
    default_attributes[:explicit_exits]
  end

  def self.explicit_exits=(bool)
    set_default explicit_exits: bool
  end
end

module StandardMethods
  # Create portals between rooms.
  #
  # @return [Portal]
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
end

Room.module_exec self do |plot|
  # Define the connect method dynamically so the plot is available
  define_method :connect do |destination, direction = nil, type: Portal, two_way: true|
    plot.connect self, destination, direction, type: Portal, two_way: true
  end
end
