module Gamefic

	class Engine
		def initialize(plot = nil)
			@plot = plot || Story.instance
		end
		def run
			user = User.new
			@plot.introduce user.character
			while true
				user.stream.select
				user.state.update
				@plot.update
			end
		end
	end

end
