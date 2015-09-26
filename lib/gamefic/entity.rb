require "gamefic/node"
require "gamefic/describable"
require "gamefic/plot"

module Gamefic

  class Entity
    include Node
    include Describable
    attr_reader :session, :plot
    def initialize(plot, args = {})
      if (plot.kind_of?(Plot) == false)
        raise "First argument must be a Plot"
      end
      pre_initialize
      @plot = plot
      @plot.send :add_entity, self
      args.each { |key, value|
        send "#{key}=", value
      }
      @update_procs = Array.new
      @session = Hash.new
      yield self if block_given?
      post_initialize
    end
    def uid
      if @uid == nil
        @uid = self.object_id.to_s
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
      if node != nil and node.kind_of?(Entity) == false
        raise "Entity's parent must be an Entity"
      end
      super
    end
    def destroy
      self.parent = nil
      # TODO: Need to call this private method here?
      @plot.send(:rem_entity, self)
    end
    def [](key)
      session[key]
    end
    def []=(key, value)
      session[key] = value
    end
    def find(description)
      query = Query::Children.new
      results = query.execute(self, description)
      if results.objects.length != 1
        raise "Find failed for #{description} on #{definitely}"
      end
      return results.objects[0]
    end
  end

end
