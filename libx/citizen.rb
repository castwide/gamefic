require "libx/personified"

module Gamefic

	class Citizen < Character
		include Personified
		def post_initialize
			super
			personify
			@synonyms = proper_name.full
			on_update do |char|
				if rand(20) == 1
					portals = char.parent.children.that_are(Portal)
					char.perform "go #{portals.random.name}"
				end
			end
		end
		def name
			"#{physique} #{gender_noun}"
		end
		def name
			"a #{physique} #{gender_noun}"
		end
	end
	class Fugitive < Citizen

	end

end
