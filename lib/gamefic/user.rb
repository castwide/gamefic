module Gamefic
	
	class User
		attr_reader :state, :character, :story
		def initialize(story)
			@story = story
			@stream = UserStream.new
			@state = UserState.new self
		end
		def stream
			@stream
		end
		def state=(state_class)
			@state = state_class.new self
		end
		def character=(entity)
			@character = entity
			@character.connect self
		end
		def refresh
			# Nothing to do
		end
		def story
			@story
		end
		def quit
			exit
		end
	end
	
	class UserStream
		def initialize
			@queue = Array.new
		end
		def send(data)
			print data
		end
		def select
			print "> "
			@queue.push STDIN.gets
		end
		def recv
			@queue.shift
		end
	end
	
	class UserState
		attr_reader :user
		def initialize(user)
			@user = user
			post_initialize
		end
		def post_initialize
			@user.character = Character.new user.story, :name => 'Player'
		end
		def update
			line = @user.stream.recv
			if line != nil
				@user.character.perform line
			end
		end
	end

end
