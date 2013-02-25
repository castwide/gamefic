require "lib/entities/portal.rb"

module Gamefic

	class Room < Entity
		def post_initialize
		
		end
		def connect(destination, direction, type = Portal, two_way = true)
			portal = type.new({
				:name => direction,
				:parent => self,
				:destination => destination
			})
			if two_way == true
				portal = type.new({
					:name => Portal.reverse(direction),
					:parent => destination,
					:destination => self
				})
			end
			self
		end
		def tell(message, refresh = false)
			children.each { |c|
				c.tell message, refresh
			}
		end
	end

end
