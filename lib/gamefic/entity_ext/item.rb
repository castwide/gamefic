require "gamefic/entity_ext/itemized"
require "gamefic/entity_ext/portable"

module Gamefic

	class Item < Entity
		include Itemized
		include Portable
	end

end
