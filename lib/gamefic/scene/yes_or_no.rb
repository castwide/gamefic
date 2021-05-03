module Gamefic
  # Prompt the user to answer "yes" or "no". The scene will accept variations
  # like "YES" or "n" and normalize the answer to "yes" or "no" in the finish
  # block. After the scene is finished, the :active scene will be cued if no
  # other scene has been prepared or cued.
  #
  class Scene::YesOrNo < Scene::Base
    attr_writer :invalid_message

    def post_initialize
      self.type = 'YesOrNo'
      self.prompt = 'Yes or No:'
    end

    # True if the actor's answer is Yes.
    # Any answer beginning with letter Y is considered Yes.
    #
    # @return [Boolean]
    def yes?
      input.to_s[0,1].downcase == 'y' or input.to_i == 1
    end

    # True if the actor's answer is No.
    # Any answer beginning with letter N is considered No.
    #
    # @return [Boolean]
    def no?
      input.to_s[0,1].downcase == 'n' or input.to_i == 2
    end

    # The message sent to the user for an invalid answer, i.e., the input
    # could not be resolved to either Yes or No.
    #
    # @return [String]
    def invalid_message
      @invalid_message ||= 'Please enter Yes or No.'
    end

    def finish
      if yes? or no?
        super
      else
        actor.tell invalid_message
      end
    end

    def state
      super.merge options: ['Yes', 'No']
    end
  end
end
