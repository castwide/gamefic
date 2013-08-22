require "gamefic/entity_ext/portal"

module Gamefic

	class Room < Entity
		def post_initialize
		
		end
		def connect(destination, direction, type = Portal, two_way = true)
			portal = type.new self.plot, :name => direction, :parent => self, :destination => destination
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
			end
			portal
		end
		def tell(message, refresh = false)
			children.each { |c|
				c.tell message, refresh
			}
		end
	end

end
