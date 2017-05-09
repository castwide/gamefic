module Gamefic

  # Active Scenes handle the default command prompt, where input is parsed
  # into an Action performed by the Character. This is the default scene in
  # a Plot.
  #
  class Scene::Active < Scene::Base
    def finish
      super
      o = nil
      o = actor.perform input.strip unless input.nil?
      actor.performed o
    end
  end
  
end
