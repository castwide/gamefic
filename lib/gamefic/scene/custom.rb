module Gamefic
  
  # A Custom Scene is a generic scene that allows for complete configuration
  # of its behavior upon instantiation. It is suitable for direct instantiation
  # or extension by other Scene classes.
  #
  class Scene::Custom < Scene::Base
    def initialize
      yield self if block_given?
    end

    def data_class
      SceneData::Base
    end

    def on_start &block
      @start = block
    end


    def on_finish &block
      @finish = block
    end

    def start actor
      data = start_data_for(actor)
      do_start_block actor, data
      data
    end

    def finish actor, input
      data = finish_data_for(actor, input)
      do_finish_block actor, data
    end

    def prompt_for actor
      character_data[actor].prompt
    end

    private

    def do_start_block actor, data
      @start.call actor, data unless @start.nil?
    end

    def do_finish_block actor, data
      @finish.call actor, data unless @finish.nil?
    end

    def character_data
      @character_data ||= {}
    end

    def start_data_for actor
      character_data[actor] ||= data_class.new
    end

    def finish_data_for actor, input
      data = character_data[actor]
      data.input = input.strip
      data
    end
  end
  
end
