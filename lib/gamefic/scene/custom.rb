module Gamefic
  
  # A Custom Scene allows for complete configuration of its behavior upon
  # instantiation. It is suitable for direct instantiation or subclassing.
  #
  class Scene::Custom < Scene::Base
    def initialize
      yield self if block_given?
    end

    def data_class
      SceneData::Base
    end

    # Define a block to be executed at the start of the scene.
    # Unlike on_finish, start blocks may be executed more than once per turn,
    # and more than one scene may be started in a single turn.
    # It always gets executed in a plot's on_ready event and whenever it gets
    # cued. (If the character is already in the scene being cued, on_start
    # does not get repeated.)
    #
    # @yieldparam [Character]
    # @yieldparam [SceneData::Base]
    def on_start &block
      @start = block
    end

    # Define a block to be executed at the end of the scene.
    # The scene data passed to this block will include the character's input
    # for this turn.
    # Unlike on_start, finish only gets executed once per turn, during the
    # plot's on_update event.
    #
    # @yieldparam [Character]
    # @yieldparam [SceneData::Base]
    def on_finish &block
      @finish = block
    end

    # Start the scene.
    # This method typically gets called from the plot during the on_ready
    # event and whenever a character cues a scene.
    #
    def start actor
      data = start_data_for(actor)
      do_start_block actor, data
      data
    end

    # End the scene.
    # This method typically gets called from the plot during the on_update
    # event.
    #
    def finish actor, input
      data = finish_data_for(actor, input)
      do_finish_block actor, data
    end

    # Get the text to be displayed to the user when receiving input.
    #
    # @return [String]
    def prompt_for actor
      return character_data[actor].prompt unless character_data[actor].nil?
      '>'
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
