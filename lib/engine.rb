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
		def initialize story
			@story = story
		end
		def user_class
			raise NotImplementedError, "Engine must be extended or inherited to implement the user_class method"
		end
		def run
			raise NotImplementedError, "Engine must be extended or inherited to implement the run method"
		end
	end
	
	class User
		attr_reader :state
		attr_accessor :character
		def initialize
			@state = initial_state_class.new self
		end
		def initial_state_class
			raise NotImplementedError
		end
		def send(message)
			raise NotImplementedError, "#{self.class} must implement send"
		end
		def recv
			raise NotImplementedError, "#{self.class} must implement recv"
		end
		def update
			#raise NotImplementedError, "#{self.class} must implement update"
			state.update
		end
		def refresh
			raise NotImplementedError, "#{self.class} must implement refresh"
		end
		def character=(entity)
			@character = entity
			@character.connect self
		end
		def state=(state_class)
			@state = state_class.new self
		end
		class State
			attr_reader :user
			def initialize(user)
				@user = user
				post_initialize
			end
			def post_initialize
				raise NotImplementedError, "#{self.class} must implement post_initialize"
			end
			def update
				raise NotImplementedError, "#{self.class} must implement update"
			end
		end
	end

end
