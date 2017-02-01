module Gamefic
  
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
  class Scene::Base
    def start actor
      start_data_for actor
    end

    def finish actor, input
      finish_data_for actor, input
    end
    
    def type
      self.class.to_s.split('::').last
    end

    def data_class
      SceneData::Base
    end

    # Get the prompt to be displayed to the user when accepting input.
    #
    # @return [String] The text to be displayed.
    def prompt_for actor
      character_data[actor].prompt || '>'
    end

    private

    def character_data
      @character_data ||= {}
    end

    def start_data_for actor
      character_data[actor] = data_class.new
    end

    def finish_data_for actor, input
      data = character_data[actor]
      data.input = input.strip
      data
    end
  end
  
end
