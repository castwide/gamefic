module Gamefic

	class Portal < Entity
		attr_writer :destination
		#def initialize
		#	super
		#	@destination = nil
		#end
		def self.reverse(direction)
			case direction.downcase
				when "north"
					"south"
				when "south"
					"north"
				when "west"
					"east"
				when "east"
					"west"
				when "northwest"
					"southeast"
				when "southeast"
					"northwest"
				when "northeast"
					"southwest"
				when "southwest"
					"northeast"
				when "up"
					"down"
				when "down"
					"up"
				else
					nil
			end
		end
		def destination
			@destination
		end
	end

end
