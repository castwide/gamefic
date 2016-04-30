module Gamefic

  class Scene::YesOrNo < Scene::Custom
    def initialize prompt = nil, &block
      @prompt = prompt
      @finish = block
    end
    def finish actor, input
      answer = nil
      if input.downcase[0, 1] == "y"
        answer = "yes"
      elsif input.downcase[0, 1] == "n"
        answer = "no"
      end
      if answer.nil?
        actor.tell "Please enter Yes or No."
      else
        @finish.call actor, answer
      end
    end
  end

end
