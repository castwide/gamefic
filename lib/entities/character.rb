module Gamefic

	class Character < Entity
		attr_reader :state, :queue, :user
		attr_accessor :story
		def post_initialize
			self.state = Ready
			@queue = Array.new
		end
		def perform(command)
			@queue.push command
			@state.update
		end
		def connect(user)
			@user = user
		end
		def disconnect
			@user = nil
		end
		def perform(command)
			if command != nil
				@queue.push command
			end
		end
		def inject(command)
			Director.dispatch(self, command)
		end
		def tell(message)
			if user != nil and message.to_s != ''
				user.puts message
			end
		end
		def flush
			@state.flush
		end
		class Ready < State
			def flush
				command = @entity.user.queue.shift
				if command != nil
					Director.dispatch(@entity, command)
				end
			end
			def update
				command = @entity.queue.shift
				if command != nil
					Director.dispatch(@entity, command)
					# Keep executing queued commands while the current state allows it
					while @entity.queue.length > 0 and @entity.state == self.class
						Director.dispatch(@entity, @entity.queue.shift)
					end
				end
			end
		end
	end

end
