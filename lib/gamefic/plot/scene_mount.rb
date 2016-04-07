class NotConclusionError < Exception
end

module Gamefic

  module Plot::SceneMount
    def scene_managers
      if @scene_managers.nil?
        @scene_managers ||= {}
        @scene_managers[:active] = ActiveSceneManager.new
        @scene_managers[:concluded] = ConcludedSceneManager.new
      end
      @scene_managers
    end
    def multiple_choice key, *args, &block
      scene_managers[key] = MultipleChoiceSceneManager.new do |config|
        config.start do |actor, data|
          data.options = args
        end
        config.finish(&block)
      end
    end
    # @yieldparam [Character]
    # @yieldparam [YesOrNoSceneData]
    def yes_or_no key, prompt = nil, &block
      manager = YesOrNoSceneManager.new do |config|
        config.prompt = prompt
        config.finish do |actor, data|
          if data.answer.nil?
            actor.tell "Please answer Yes or No."
          else
            block.call(actor, data)
            if actor.scene.key == key
              # TODO: Not sure the :active scene should be hardcoded here, but
              # YesOrNoSceneData does not have a next_cue property.
              cue actor, :active
            end
          end
        end
      end
      scene_managers[key] = manager
    end
    def prompt key, prompt, &block
      scene_managers[key] = SceneManager.new do |config|
        config.prompt = prompt
        config.finish do |actor, data|
          data.next_cue ||= :active
          block.call actor, data
          cue actor, data.next_cue
        end
      end
      scene_managers[key].state = "Prompted"
    end  
    def pause key, &block
      manager = PausedSceneManager.new do |config|
        config.start do |actor, data|
          data.next_cue = :active
          block.call actor, data
        end
        config.finish do |actor, data|
          if actor.scene.key == key
            cue actor, (data.next_cue || :active)
          end
        end
      end
      scene_managers[key] = manager
    end
    # @yieldparam [Character]
    def conclusion key, &block
      manager = ConcludedSceneManager.new do |config|
        config.start(&block)
      end
      scene_managers[key] = manager
    end
    def scene key, &block
      scene = SceneManager.new do |manager|
        manager.start do |actor, data|
          block.call(actor, data)
          data.next_cue = :active
        end
        manager.finish do |actor, data|
          cue actor, data.next_cue
        end
      end
      scene_managers[key] = scene
    end
    def branch key, options
      multiple_choice key, *options.keys do |actor, data|
        cue actor, options[data.selection]
      end
    end
    def cue actor, key
      if !actor.scene.nil? and actor.scene.state == "Concluded"
        return
      end
      if key.nil?
        raise "Cueing scene with nil key"
      end
      manager = scene_managers[key]
      if manager.nil?
        #actor.scene = nil
        raise "No '#{key}' scene found"
      else
        actor.scene = manager.prepare key
        if actor.scene.state == 'Passive'
          actor.scene.start actor
          actor.scene.finish actor, nil
        end
        # TODO The plot might be responsible for executing scenes in Plot#update
        #actor.scene.NOT_A_start actor
      end
      @scene
    end
    # This is functionally identical to #cue, but it also raises an
    # exception if the selected scene is not a Concluded state.
    def conclude actor, key
      key = :concluded if key.nil?
      manager = scene_managers[key]
      if manager.state != "Concluded"
        raise NotConclusionError("Cued scene '#{key}' is not a conclusion")
      end
      cue actor, key
    end
  end

end
