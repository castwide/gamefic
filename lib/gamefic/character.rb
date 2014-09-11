require "gamefic/character/state"

module Gamefic

	class Character < Thing
		attr_reader :state, :state_name, :queue, :user, :last_command
    attr_accessor :object_of_pronoun
		def initialize(plot, args = {})
			#set_state CharacterState::Active
			@queue = Array.new
      super
      self.state = :active
		end
		def connect(user)
			@user = user
		end
		def disconnect
			# TODO: We might need some cleanup here. Like, move the character out of the game, or set a timeout to allow dropped users to reconnect... figure it out.
			@user = nil
		end
		def perform(*command)
      @last_command = command
			if state.busy? == false
				Director.dispatch(self, *command)
			else
        # TODO: The queue needs to accept both arrays and strings
				@queue.push command
			end
		end
    def state
      @state
    end
    def state=(name)
      if plot.states[name].nil?
        raise "Invalid state #{name}"
      end
      @state_name = name
      @state = plot.states[name]
    end
		def tell(message)
			if user != nil and message.to_s != ''
				user.stream.send "#{message}\n\n"
			end
		end
    def stream(message)
      if user != nil and message.to_s != ''
        user.stream.send message
      end
    end
    #def send(message)
    #  user.stream.send message
    #end
    #def set_state name
    #  @state = @plot.states[name]
    #end
		def destroy
			if @user != nil
				@user.quit
			end
			super
		end
		def update
			super
			@state.update self
		end
	end

end
