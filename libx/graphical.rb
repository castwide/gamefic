module Gamefic
	class Entity
		attr_accessor :image, :map_command
		def image
			@image || default_image
		end
		def map_command
			@map_command || default_map_command
		end
		private
		def default_image
			"unknown.png"
		end
		def default_map_command
			"^look #{self.uid}"
		end
	end
	class Character
		def default_image
			"person.png"
		end
	end
	class Portal
		def map_command
			"go #{self.uid}"
		end
	end
	class Container
		def default_map_command
			"^search #{self.uid}"
		end
		def default_image
			"box.png"
		end
	end
	class Room
		def default_image
			"pixel.png"
		end
	end
end
