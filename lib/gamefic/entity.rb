require "digest/md5"
require "gamefic/node"
require "gamefic/describable"
require "gamefic/story"

module Gamefic
	
	class Entity
		include Branch
		include Describable
		attr_reader :session, :story
		def initialize(args = {})
			pre_initialize
			#self.state = State
			@story = Subplot.current
			@story.add_entity self
			args.each { |key, value|
				send "#{key}=", value
			}
			@update_procs = Array.new
			@session = Hash.new
			post_initialize
		end
		def uid
			if @uid == nil
				@uid = Digest::MD5.hexdigest(self.object_id.to_s)[0,8]
			end
			@uid
		end
		def pre_initialize
			# raise NotImplementedError, "#{self.class} must implement post_initialize"		
		end
		def post_initialize
			# raise NotImplementedError, "#{self.class} must implement post_initialize"
		end
		def tell(message, refresh = false)
			#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
			#TODO: On second thought, it might be interesting to see logs from an npc point of view.
		end
		def to_s
			name
		end
		#def state
		#	@state.class
		#end
		#def state=(state_class)
		#	@state = state_class.new(self)
		#end
		def update
			@update_procs.each { |p|
				p.call self
			}
		#	@state.update
		end
		def on_update(&block)
			@update_procs.push block
		end
		def parent=(node)
			if node != nil and node.kind_of?(Entity) == false and node.kind_of?(Zone) == false
				raise "Entity's parent must be an Entity or a Zone"
			end
			super
		end
		def destroy
			self.parent = nil
			@story.rem_entity self
		end
		#class State
		#	attr_reader :character
		#	def initialize(entity)
		#		@entity = entity
		#		post_initialize
		#	end
		#	def post_initialize
		#	
		#	end
		#	def update
		#		# Nothing to do
		#	end
		#end
	end

end
