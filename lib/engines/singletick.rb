require "lib/engine"

module Gamefic

	module SingleTick
		def user_class
			SingleUser
		end
		def run
			user = user_class.new
			user.character = Player.new :name => 'you'
			story.introduce user.character
			last_tick = Time.new
			while true
				user.update
				diff = Time.new.to_f - last_tick.to_f
				if diff >= 1.0
					story.update
					last_tick = Time.new
				end
			end
		end
		class SingleUser < User
			def initial_state_class
				SingleTick::Play
			end
			def recv
				resp = select([STDIN], nil, nil, 0.01)
				if resp != nil
					return STDIN.gets.strip
				end
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
