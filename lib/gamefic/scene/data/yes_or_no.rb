module Gamefic

  class Scene::Data::YesOrNo < Scene::Data::Base
    def yes?
      input.to_s[0,1].downcase == 'y'
    end
    def no?
      input.to_s[0,1].downcase == 'n'
    end
    def prompt
      @prompt ||= 'Yes or No?'
    end
    def invalid_message
      @invalid_message ||= 'Please enter Yes or No.'
    end
  end

end
