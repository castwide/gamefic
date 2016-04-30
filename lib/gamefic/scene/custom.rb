module Gamefic
  
  class Scene::Custom < Scene::Base
    def initialize config = {}
      @start = config[:start]
      @finish = config[:finish]
      @prompt = config[:prompt]
    end
    def start actor
      @start.call(actor) unless @start.nil?
    end
    def finish actor, input
      @finish.call(actor, input) unless @finish.nil?
    end
  end
  
end
