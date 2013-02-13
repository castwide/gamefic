module Gamefic

	class Character < Entity
		def perform(command)
			Delegate.dispatch(self, command)
		end
	end

end
