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
    attr_accessor :index, :selection, :options
    def options
      @options ||= []
    end
  end

  class MultipleChoiceScene < Scene
    def initialize manager, key
      super
      @end_prompt = @prompt || "Enter a choice:"
    end
    def start actor
      super
      list = []
      index = 1
      @data.options.each { |o|
        list.push "#{index}. #{o}"
        index += 1
      }
      @data.prompt = "#{list.join("\n")}\n#{@end_prompt}"
    end
    def finish actor, input
      @data.input = input
      @data.index = nil
      @data.selection = nil
      index = input.to_i
      if @data.options[index - 1].nil?
        # TODO: Consider allowing for an error block to customize this
        # response.
        actor.tell "That's not a valid selection."
      else
        return if @finish.nil?
        @data.index = index - 1
        @data.selection = @data.options[index - 1]
        @finish.call actor, data
      end
    end
  end

end
