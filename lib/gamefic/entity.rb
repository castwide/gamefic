require "digest/md5"
require "gamefic/node"
require "gamefic/describable"
require "gamefic/plot"

module Gamefic

	class Entity
		include Branch
		include Describable
    include OptionSettings
		attr_reader :session, :plot
		def initialize(plot, args = {})
			if (plot.kind_of?(Plot) == false)
				raise "First argument must be a Plot"
			end
			pre_initialize
			#self.state = State
			#@story = Subplot.current
			@plot = plot
      @option_mapper = @plot
			@plot.send :add_entity, self
			#@story.add_entity self
			args.each { |key, value|
				send "#{key}=", value
			}
			@update_procs = Array.new
			@session = Hash.new
			post_initialize
		end
    def options=(array)
      array.each { |option|
        is option
      }
    end
		#def self.present(args = {})
		#	story = Plot.Loading
		#	if story == nil
		#		raise "No plot loading"
		#	end
		#	return self.new(story, args)
		#end
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
		def tell(message)
			#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
			#TODO: On second thought, it might be interesting to see logs from an npc point of view.
		end
    def stream(message)
      # Unlike tell, this method sends raw data without formatting.
    end
		def update
			@update_procs.each { |p|
				p.call self
			}
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
			# TODO: Need to call this private method here?
			@plot.send(:rem_entity, self)
		end
	end

end
