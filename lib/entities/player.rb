module Gamefic

	class Player < Character
		def perform(command)
			# If the character is in a Ready start, execute
			# the action immediately. This is a courtesy to
			# reduce lag in networked games. Without it, user
			# input would not get processed until the next
			# tick.
			if @state.class == Character::Ready
				Director.dispatch self, command
			else
				super
			end
		end
	end

end
