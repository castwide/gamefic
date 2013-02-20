module Gamefic
	class SingleTurn < Game
		attr_reader :story
		def initialize(story)
			@story = story
		end
		def enroll(user)
			@user = user
			@player = Player.new
			@player.parent = @story
			@player.name = "player"
			@player.connect user
			@story.introduce @player
		end
		def run
			while true
				@user.send "[#{@player.parent.name.cap_first}]>"
				@player.perform @user.recv
				@story.update
			end
		end
		class User
			attr_accessor :state, :name
			def initialize(state_class = Play)
				self.state = state_class
			end
			def state=(state_class)
				@state = state_class.new(self)
			end
			def send(message)
				print message
			end
			def puts(message)
				send "#{message}\n"
			end
			def recv
				return STDIN.gets.strip
			end
			class State
				attr_reader :user
				def initialize(user)
					@user = user
					post_initialize
				end
				def post_initialize
					raise NotImplementedError
				end
				def update(message)
					raise NotImplementedError
				end
			end
			class Play < State
				def post_initialize
					#puts "post_initialize"
				end
				def update
					puts "Nothing to do here, really?"
				end
			end
		end
	end
end
