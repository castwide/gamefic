module Gamefic

  module Gamefic::Plot::SceneMount
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
        config.finish &block
      end
    end
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
        config.finish &block
      end
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
    def conclusion key, &block
      manager = ConcludedSceneManager.new do |config|
        config.start &block
      end
      scene_managers[key] = manager
    end
    def scene key, &block
      scene = SceneManager.new do |manager|
        manager.start do |actor, data|
          block.call(actor, data)
          cue actor, :active
        end
      end
      scene_managers[key] = scene
    end
    def cue actor, key
      if !actor.scene.nil? and actor.scene.state == "Concluded"
        return
      end
      if key.nil?
        key = plot.default_scene
      end
      manager = scene_managers[key]
      if manager.nil?
        actor.scene = nil
      else
        actor.scene = manager.prepare key
        actor.scene.start actor
      end
      @scene
    end
    # This is functionally identical to #cue, but it also raises an
    # exception if the selected scene is not a Concluded state.
    def conclude actor, key
      key = :concluded if key.nil?
      manager = scene_managers[key]
      if manager.state != "Concluded"
        raise "Selected scene '#{key}' is not a conclusion"
      end
      cue actor, key
    end
  end

end
