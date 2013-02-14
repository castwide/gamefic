module Gamefic

	class Car < Entity
		include Itemized
	end

	class Waypoint < Room
		attr_writer :location
		def location
			@location.to_s != '' ? @location : longname
		end
		def synonyms
			"#{super} #{location}"
		end
	end

end
