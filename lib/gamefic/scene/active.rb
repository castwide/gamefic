module Gamefic

  # Active Scenes handle the default command prompt, where input is parsed
  # into an Action performed by the Character. This is the default scene in
  # a Plot.
  #
  class Scene::Active < Scene::Base
    def post_initialize
      self.type = 'Active'
    end

    def finish
      super
      o = nil
      o = actor.perform input.strip unless input.nil?
      actor.performed o
    end

    class << self
      def type
        'Active'
      end
    end
  end
  
end
