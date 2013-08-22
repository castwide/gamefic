module Gamefic

	class Portal < Entity
		attr_accessor :destination
		#def initialize
		#	super
		#	@destination = nil
		#end
    def find_reverse
      rev = Portal.reverse(self.name)
      if rev != nil
        destination.children.that_are(Portal).each { |c|
          if c.name == rev
            return c
          end
        }
      end
    end
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
	end

end
