require "lib/entities/portal.rb"

module Gamefic

	class Room < Entity
		def post_initialize
		
		end
		def connect(destination, direction, type = Portal, two_way = true)
			portal = type.new(root, {
				:name => direction,
				:parent => self,
				:destination => destination
			})
			if two_way == true
				portal = type.new(root, {
					:name => Portal.reverse(direction),
					:parent => destination,
					:destination => self
				})
			end
			self
		end
		def tell(message)
			children.each { |c|
				c.tell message
			}
		end
	end

end
