module Gamefic

  # Active Scenes handle the default command prompt, where input is parsed
  # into an Action performed by the Character. This is the default scene in
  # a Plot.
  #
  class Scene::Active < Scene::Base
    attr_reader :plot

    def initialize plot
      @plot = plot
    end

    def finish actor, input
      o = Director.dispatch plot, actor, input
      actor.performed o
    end
  end
  
end
