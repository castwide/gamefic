module Gamefic

  class Scene::MultipleScene < Scene::MultipleChoice
    def option_map
      @option_map ||= {}
    end

    # @param option [String]
    # @param scene [Class<Gamefic::Scene::Base>]
    def map option, scene
      options.push option
      option_map[option] = scene
    end

    def finish
      get_choice
      unless selection.nil?
        actor.prepare option_map[selection]
      end
    end

    def state
      entered = {}
      option_map.each_pair do |k, v|
        entered[k] = actor.entered?(v)
      end
      super.merge entered: entered
    end
  end
end
