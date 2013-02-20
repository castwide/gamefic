require "lib/node"
require "lib/describable"

module Gamefic
	
	class Entity
		include Branch
		include Describable
		def initialize(args = {})
			self.state = State
			args.each { |key, value|
				send "#{key}=", value
			}
			@update_procs = Array.new
			post_initialize
		end
		def post_initialize
			# raise NotImplementedError, "#{self.class} must implement this method"
		end
		def tell(message)
			#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
			#TODO: On second thought, it might be interesting to see logs from an npc point of view.
		end
		def to_s
			@name
		end
		def state
			@state.class
		end
		def state=(state_class)
			@state = state_class.new(self)
		end
		def update
			@update_procs.each { |p|
				p.call self
			}
			@state.update
		end
		def on_update(&block)
			@update_procs.push block
		end
		class State
			attr_reader :character
			def initialize(entity)
				@entity = entity
			end
			def update
				# Nothing to do
			end
		end
	end

end
