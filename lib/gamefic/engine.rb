module Gamefic

	class Engine
		def initialize(plot)
			@plot = plot
		end
		def run
			user = User.new @plot
      @plot.introduce user.character
			while user.character.state.kind_of?(GameOverState) == false
        proc {
          $SAFE = 3
          user.stream.select user.character.state.prompt
          print "\n"
          user.state.update
          @plot.update
        }.call
			end
		end
	end

end
