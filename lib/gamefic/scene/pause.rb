module Gamefic
  # Pause for user input.
  #
  class Scene::Pause < Scene::Base
    def post_initialize
      self.type = 'Pause'
      self.prompt = 'Press enter to continue...'
    end

    class << self
      def tracked?
        @tracked = true if @tracked.nil?
        @tracked
      end
    end
  end
end
