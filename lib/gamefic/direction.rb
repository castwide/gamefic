module Gamefic
  # A collection of methods that are common to plots and subplots.
  module Direction
    include Scripting
    extend Scripting::ClassMethods

    def takes
      @takes ||= []
    end

    # Introduce a player to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      @introduced = true
      player.playbooks.push playbook unless player.playbooks.include?(playbook)
      player.scenebooks.push scenebook unless player.scenebooks.include?(scenebook)
      players_safe_push player
      player.select_cue :introduction, default_scene
    end

    def start_production
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
      default_scene && default_conclusion # Make sure they exist
      playbook.freeze
      scenebook.freeze
    end

    # @param actor [Actor]
    # @return [Actor]
    def exeunt actor
      scenebook.player_conclude_blocks.each { |blk| blk.call actor }
      actor.scenebooks.delete scenebook
      actor.playbooks.delete playbook
      players_safe_delete actor
    end

    def ready
      scenebook.ready_blocks.each(&:call)
      prepare_takes
      start_takes
    end

    def update
      finish_takes
      players.each do |plyr|
        scenebook.player_update_blocks.each { |blk| blk.call plyr }
      end
      scenebook.update_blocks.each(&:call)
    end

    # Cast an active entity.
    # This method is similar to make, but it also provides the plot's
    # playbook and scenebook to the entity so it can perform actions and
    # participate in scenes. The entity should be an instance of
    # Gamefic::Actor or include the Gamefic::Active module.
    #
    # @return [Gamefic::Actor, Gamefic::Active]
    def cast cls, **args
      ent = make cls, **args
      ent.playbooks.push playbook
      ent.scenebooks.push scenebook
      ent
    end

    private

    def prepare_takes
      takes.replace(players.map do |pl|
        pl.start_cue default_scene
      end)
    end

    def start_takes
      takes.each do |take|
        scenebook.run_player_ready_blocks take.actor
        take.start
        scenebook.run_player_output_blocks take.actor, take.output
      end
    end

    def finish_takes
      takes.each do |take|
        take.finish
        next if take.cancelled? || take.scene.type != 'Conclusion'

        exeunt take.actor
      end
      takes.clear
    end
  end
end
