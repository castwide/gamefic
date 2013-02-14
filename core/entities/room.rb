require "core/entities/portal.rb"

module Gamefic

	class Room < Entity
		def connect(destination, direction, type = Portal, two_way = true)
			portal = type.create(
				:name => direction,
				:parent => self,
				:destination => destination
			)
			if two_way == true
				portal = type.create(
					:name => Portal.reverse(direction),
					:parent => destination,
					:destination => self
				)
			end
			self
		end
	end

end
