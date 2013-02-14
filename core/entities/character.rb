module Gamefic

	class Character < Entity
		def perform(command)
			Director.dispatch(self, command)
		end
	end

end
