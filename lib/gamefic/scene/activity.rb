module Gamefic
  # Active Scenes handle the default command prompt, where input is parsed
  # into an Action performed by the Character. This is the default scene in
  # a Plot.
  #
  class Scene::Activity < Scene::Base
    def post_initialize
      self.type = 'Activity'
    end

    def finish
      super
      o = nil
      o = actor.perform input.strip unless input.to_s.strip.empty?
      actor.performed o
    end

    class << self
      def type
        'Activity'
      end
    end
  end
end
