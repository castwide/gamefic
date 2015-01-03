module Gamefic

  class MultipleChoiceSceneManager < SceneManager
    def data_class
      MultipleChoiceSceneData
    end
    def scene_class
      MultipleChoiceScene
    end
    def state
      @state ||= "MultipleChoice"
    end
  end
  
  class MultipleChoiceSceneData < SceneData
    attr_accessor :index
    attr_accessor :selection
    def options
      @options ||= []
    end
  end

  class MultipleChoiceScene < Scene
    def finish actor, input
      @data.input = input
      @data.index = nil
      @data.selection = nil
      index = input.to_i
      if @data.options[index - 1].nil?
        # TODO: This should not raise an exception. It's just a placeholder
        # until I configure a practical proc to handle invalid input.
        raise "Invalid selection"
      else
        return if @finish.nil?
        @data.index = index - 1
        @data.selection = @data.options[index - 1]
        @finish.call actor, data
      end
    end
  end

end
