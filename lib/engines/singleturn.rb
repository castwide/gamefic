require "lib/engine"

module Gamefic
	
	module SingleTurn
		def user_class
			SingleUser
		end
		def run
			user = user_class.new
			user.character = Player.new :name => 'you'
			story.introduce user.character
			last_tick = Time.new
			while true
				print "[#{user.character.parent.name.cap_first}]>"
				user.update
				story.update
			end
		end
		class SingleUser < User
			def initial_state_class
				SingleTurn::Play
			end
			def recv
				return STDIN.gets.strip
			end
			def send(message)
				puts message
			end
			def refresh
				# Nothing to do?
			end
		end
		class Play < User::State
			def post_initialize
				user.send "Welcome to Gamefic!\n"
			end
			def update
				line = user.recv
				if line != nil
					user.character.perform line
				end
			end
		end
	end

end
