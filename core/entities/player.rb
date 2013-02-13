module Gamefic

	class Player < Character
		def perform(command)
			super command
		end
		def tell(message)
			if message.to_s != ''
				puts message.terminalize
			end
		end
	end

end
