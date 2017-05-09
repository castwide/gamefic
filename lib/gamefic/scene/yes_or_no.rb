module Gamefic

  # Prompt the user to answer "yes" or "no". The scene will accept variations
  # like "YES" or "n" and normalize the answer to "yes" or "no" in the finish
  # block. After the scene is finished, the :active scene will be cued if no
  # other scene has been prepared or cued.
  #
  class Scene::YesOrNo < Scene::Custom
    def yes?
      input.to_s[0,1].downcase == 'y'
    end

    def no?
      input.to_s[0,1].downcase == 'n'
    end

    def invalid_message
      @invalid_message ||= 'Please enter Yes or No.'
    end

    def prompt
      @prompt ||= 'Yes or No?'
    end

    def finish
      if yes? or no?
        super
      else
        actor.tell invalid_message
      end
    end
  end

end
