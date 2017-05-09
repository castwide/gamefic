module Gamefic

  # Pause for user input.
  #
  class Scene::Pause < Scene::Custom

    def post_initialize
      STDERR.puts "Post initialize #{self.class.ancestors.join(';')}"
      self.type = 'Pause'
      self.prompt = 'Press enter to continue...'
      STDERR.puts "Prompt is #{self.prompt}"
    end

    def finish
      super
      actor.cue nil if actor.will_cue?(self)
    end
  end
  
end
