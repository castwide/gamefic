module Gamefic

  class Scene::Data::Base
    attr_writer :prompt
    attr_accessor :input
    
    def prompt
      @prompt ||= '>'
    end
  end

end
