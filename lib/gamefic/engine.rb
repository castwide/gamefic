module Gamefic

	class Engine
		def initialize(plot)
			@plot = plot
      post_initialize
		end
    def post_initialize
      @user = User.new @plot
    end
		def run
      @plot.introduce @user.character
			while @user.character.state.kind_of?(GameOverState) == false
        tick
			end
		end
    def tick
      proc {
        $SAFE = Gamefic.safe_level
        @user.stream.select @user.character.state.prompt
        @user.state.update
        @plot.update
      }.call    
    end
	end

	class User
		attr_reader :state, :character, :story
		def initialize(plot)
			@plot = plot
      @character = Character.new @plot, :name => 'yourself', :synonyms => 'self myself you me'
      @character.connect self
      post_initialize
		end
    def post_initialize
			@stream = UserStream.new
			@state = UserState.new self
    end
		def stream
			@stream ||= UserStream.new
		end
    def state
      @state ||= UserState.new(self)
    end
		def state=(state_class)
			@state = state_class.new self
		end
		def refresh
			# Nothing to do
		end
		def quit
			#exit
		end
	end
	
	class UserStream
		def initialize
			@queue = Array.new
		end
		def send(data)
      puts data
		end
		def select(prompt)
			print prompt
			line = STDIN.gets
      @queue.push line.strip
		end
		def recv
			@queue.shift
		end
	end
	
	class UserState
		attr_reader :user
		def initialize(user)
			@user = user
		end
		def update
			line = @user.stream.recv
			if line != nil
        @user.character.queue.push line
			end
		end
	end

end
