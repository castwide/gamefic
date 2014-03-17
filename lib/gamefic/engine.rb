module Gamefic

	class Engine
		def initialize(plot)
			@plot = plot
		end
		def run
			user = User.new @plot
			@plot.introduce user.character
			while user.character.state.kind_of?(GameOverState) == false
				user.stream.select user.character.state.prompt
				user.state.update
				@plot.update
			end
		end
	end

end
