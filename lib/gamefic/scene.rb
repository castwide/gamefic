module Gamefic

  # SceneManagers handle the creation and execution of player scenes.
  #
  # @example Create a scene that lets the player select a name.
  #   scene_managers[:get_name] = SceneManager.new do |manager|
  #     manager.state = "Active" # Tell the Engine that this scene accepts input
  #     manager.prompt = "Enter your name:"
  #     manager.start do |actor, data|
  #       actor.tell "Let's start with a formal introduction."
  #     end
  #     manager.finish do |actor, data|
  #       actor[:name] = data.input
  #       actor.tell "Howdy, #{actor[:name]}!"
  #       actor.next_cue = :active # Proceed to the default :active scene
  #     end
  #   end
  #
  class SceneManager
    attr_accessor :state
    attr_writer :prompt
    
    def initialize &block
      yield self if block_given?
    end
    
    # Get the SceneData class that provide data about the current event to a
    # Scene instance.
    #
    def data_class
      SceneData
    end
    
    # Get the name that describes this scene's state.
    # Two common values for the state are Active and Passive. If a scene is
    # Active, it is capable of accepting user input. If it is Passive, it
    # is probably not interactive (e.g., a cutscene) and will usually cue
    # an Active scene in order to continue gameplay.
    #
    # @return [String] The name of the state.
    def state
      @state ||= 'Passive'
    end
    
    # Get the Scene class that the SceneManager uses to prepare a scene for
    # the plot.
    #
    def scene_class
      Scene
    end
    
    # Define a Block to be executed when the scene starts. The Engine should
    # execute this block before the player is queried for input.
    #
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def start &block
      @start = block
    end
    
    # Define a Block to be executed when the scene finishes. The engine should
    # process user input in this block.
    #
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def finish &block
      @finish = block
    end
    
    # Prepare a new Scene for execution.
    #
    # @return [Scene]
    def prepare key
      scene_class.new(self, key)
    end
    
    # Get the prompt to display to the user when requesting input.
    #
    # @return [String]
    def prompt
      @prompt ||= ">"
    end
end
  
  class SceneData
    attr_accessor :input, :prompt, :next_cue
  end
  
  class Scene
    attr_reader :data, :state, :key
    
    def initialize(manager, key)
      @manager = manager
      @start = manager.instance_variable_get(:@start)
      @finish = manager.instance_variable_get(:@finish)
      @state = manager.state
      @data = manager.data_class.new
      @data.prompt = manager.prompt
      @key = key
    end
    
    # Start the scene. This method is typically called by the Plot.
    def start actor
      return if @start.nil?
      @data.input = nil
      @start.call actor, @data
    end
    
    # Finish the scene. This method is typically called by the Plot.
    def finish actor, input
      @data.next_cue ||= :active
      return if @finish.nil?
      @data.input = input
      @finish.call actor, @data
    end
  end

end
