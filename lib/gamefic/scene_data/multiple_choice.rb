module Gamefic

  class SceneData::MultipleChoice < SceneData::Base
    attr_accessor :selection
    attr_accessor :number
    attr_accessor :index
    attr_writer :invalid_message
    def options
      @options ||= []
    end
    def clear
      options.clear
    end
    def prompt
      @prompt ||= 'Enter a choice:'
    end
    def invalid_message
      @invalid_message ||= 'That is not a valid choice.'
    end
  end

end
