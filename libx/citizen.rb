module Gamefic

	class Citizen < Character
		@@randchar = RandomCharacters.new
		def post_initialize
			name = @@randchar.generate
			on_update do |char|
				if rand(10) == 1
					portals = char.parent.children.that_are(Portal)
					char.perform "go #{portals.random.name}"
				end
			end
		end
	end
	class Fugitive < Citizen

	end

end
