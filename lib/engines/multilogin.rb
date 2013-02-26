require "lib/engine"
require "lib/engines/multitick"
require "socket"

module Gamefic
	class MultiLogin < MultiTick
		attr_reader :story
		def initialize(story)
			@story = story
			@serverSocket = TCPServer.new('', 4141)
			@descriptors = Array.new
			@descriptors.push(@serverSocket)
			@users = Hash.new
		end
		def enroll(user)
			@users[user.socket] = user
			player = Player.new
			player.parent = @story
			player.name = "player #{Time.new.usec}"
			player.connect user
			@story.introduce player
			user.player = player
		end
		class User < MultiTick::User
			def initialize(socket, state_class = Login)
				super
			end
			class Login < Engine::User::State
				def post_initialize
					user.send "Login:"
				end
			end
			class Play < Engine::User::State
				def post_initialize
					# nothing to do
				end
				def update
					# nothing to do
				end
			end
		end
	end
end
