module Gamefic

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

	class User
		class State
			class Start < State
				def post_initialize
					user.send "Enter your character name or \"new\" to create a new character: "
				end
				def update(message)
					if message == "new"
						user.state = Create
					else
						user.state = Login
					end
				end
			end
			class Login < State
				def post_initialize
					user.send "Password: "
				end
				def update(message)
					valid = true # TODO: Password validation
					if (valid == true)
						user.state = Play
					else
						user.send "Invalid name or password."
						user.state = Start
					end
				end
			end
			class Play < State
				def post_initialize
					user.puts "Welcome!"
				end
				def update(message)
					raise NotImplementedError
				end
			end
		end
	end

end
