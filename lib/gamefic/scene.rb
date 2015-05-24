module Gamefic

  class SceneManager
    attr_accessor :state
    attr_writer :prompt
    def initialize &block
      yield self if block_given?
    end
    # Define a kind of SceneData to provide data about the current event to a
    # Scene instance.
    def data_class
      SceneData
    end
    # Define a kind of Scene that the SceneManager uses to prepare a scene for
    # the plot.
    def scene_class
      Scene
    end
    def start &block
      @start = block
    end
    def finish &block
      @finish = block
    end
    def prepare key
      scene_class.new(self, key)
    end
    def prompt
      @prompt ||= ">"
    end
end
  
  class SceneData
    attr_accessor :input, :prompt
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
    def start actor
      return if @start.nil?
      @data.input = nil
      @start.call actor, @data
    end
    def finish actor, input
      return if @finish.nil?
      @data.input = input
      @finish.call actor, @data
    end
  end

end
