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
		def enroll(user)
			@user = user
			@player = Player.new @story
			@player.name = "player"
			@player.connect user
			@story.introduce @player
		end
		def run
			while true
				#line = STDIN.gets.strip
				#@player.perform line
				@player.update
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
					user.send ">"
				end
				def update
					puts "Nothing to do here, really?"
				end
			end
		end
	end
end
