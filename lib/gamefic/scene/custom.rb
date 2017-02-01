module Gamefic
  
  # A Custom Scene is a generic scene that allows for complete configuration
  # of its behavior upon instantiation. It is suitable for direct instantiation
  # or extension by other Scene classes.
  #
  class Scene::Custom < Scene::Base
    def initialize
      yield self if block_given?
    end
    def on_start &block
      @start = block
    end

    def on_finish &block
      @finish = block
    end

    def start actor
      do_start_block actor, start_data_for(actor)
    end

    def finish actor, input
      data = finish_data_for(actor, input)
      do_finish_block actor, data
    end

    private

    def do_start_block actor, data
      @start.call actor, data unless @start.nil?
    end

    def do_finish_block actor, data
      @finish.call actor, data unless @finish.nil?
    end

  end
  
end
