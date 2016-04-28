module Gamefic

  class YesOrNoSceneManager < SceneManager
    def scene_class
      YesOrNoScene
    end
    def data_class
      YesOrNoSceneData
    end
    def state
      @state ||= "YesOrNo"
    end
    def prompt
      @prompt ||= "Enter Yes Or No:"
    end
  end
  
  class YesOrNoSceneData < SceneData
    # @!attribute [rw] answer
    #   @return [String] The answer provided by the user, normalized to either "yes" or "no"
    attr_accessor :answer
  end
  
  class YesOrNoScene < Scene
    def finish actor, input
      @data.input = input
      # The input in a YesOrNoScene gets normalized to "yes" or "no"
      @data.answer = nil
      if input.downcase[0, 1] == "y"
        @data.answer = "yes"
      elsif input.downcase[0, 1] == "n"
        @data.answer = "no"
      end
      if @data.answer.nil?
        actor.tell "Please enter Yes or No."
      else
        return if @finish.nil?
        @finish.call actor, data
      end
    end
  end

end
