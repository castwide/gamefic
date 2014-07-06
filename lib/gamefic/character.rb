require "gamefic/character/state"

module Gamefic

	class Character < Thing
		attr_reader :state, :queue, :user, :last_command
    attr_accessor :object_of_pronoun
		def initialize(plot, args = {})
			set_state CharacterState::Active
			@queue = Array.new
      super
		end
		def connect(user)
			@user = user
		end
		def disconnect
			# TODO: We might need some cleanup here. Like, move the character out of the game, or set a timeout to allow dropped users to reconnect... figure it out.
			@user = nil
		end
		def perform(command)
			#if command != nil
			#	@queue.push command
			#end
      @last_command = command
			if state.busy? == false
				Director.dispatch(self, command)
			else
				@queue.push command
			end
		end
		#def inject(command)
		#	Director.dispatch(self, command)
		#end
		def tell(message, refresh = false)
			if user != nil and message.to_s != ''
				user.stream.send "#{message}\n"
				if (refresh == true)
					user.refresh
				end
			end
		end
		#def state=(new_state)
		#	@state = new_state
		#end
    def set_state new_state, *args, &block
      @state = new_state.new(self, *args, &block)
    end
		def destroy
			if @user != nil
				@user.quit
			end
			super
		end
		def update
			super
			@state.update
		end
	end

end
