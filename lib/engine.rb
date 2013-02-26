require "lib/array.rb"
require "lib/string.rb"
require "lib/keywords.rb"
require "lib/entity.rb"
require "lib/zone.rb"
require "lib/action.rb"
require "lib/parser.rb"
require "lib/director.rb"
require "lib/story.rb"

Dir["lib/features/*.rb"].each { |file|
	require file
}
Dir["lib/entities/*.rb"].each { |file|
	require file
}

module Gamefic
	class Engine
		attr_reader :story
		def initialize(story)
			@story = story
		end
		def run
			@player = Player.new
			@player.name = "Player"
			@story.introduce @player
			@user = User.new
			@user.player = @player
			while true
				@story.update
				@user.update
			end
		end
		class User
			attr_accessor :player
			def initialize
				self.state = Play
			end
			def state=(state_class)
				@state = state_class.new(self)
			end
			def send(message)
				print message
			end
			def recv
				return STDIN.gets.strip
			end
			def update
				@state.update
			end
			def player=(player)
				@player = player
				@player.connect self
			end
			def refresh
				# Tell the user that there is new data ready to be requested (i.e., something on the map has changed)
			end
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
				user.puts "Welcome to Gamefic. Go to <http://gamefic.com> for news and updates.\n" 
			end
			def update
				user.send ">"
				input = user.recv
				user.player.perform input
			end
		end
	end
end
