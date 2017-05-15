module Gamefic

  module Plot::Callbacks    
    # Add a block to be executed on preparation of every turn.
    #
    # @example Increment a turn counter
    #   turn = 0
    #   on_ready do
    #     turn += 1
    #   end
    #
    def on_ready &block
      p_ready_procs.push block
    end

    # Add a block to be executed after the Plot is finished updating a turn.
    #
    def on_update &block
      p_update_procs.push block
    end

    # Add a block to be executed for each player at the beginning of a turn.
    #
    # @example Tell the player how many turns they've played.
    #   on_player_ready do |player|
    #     player[:turns] ||= 0
    #     if player[:turns] > 0
    #       player.tell "Turn #{player[:turns]}"
    #     end
    #     player[:turns] += 1
    #   end
    #
    # @yieldparam [Gamefic::Performance]
    def on_player_ready &block
      p_player_ready_procs.push block
    end

    # Add a block to be executed for each player before an update.
    #
    # @yieldparam[Character]
    def before_player_update &block
      p_before_player_update_procs.push block
    end

    # Add a block to be executed for each player at the end of a turn.
    #
    # @yieldparam [Character]
    def on_player_update &block
      p_player_update_procs.push block
    end

    private

    # Execute the on_ready blocks. This method is typically called by the
    # Plot while beginning a turn.
    #
    def call_ready
      p_ready_procs.each { |p| p.call }
    end

    # Execute the on_update blocks. This method is typically called by the
    # Plot while ending a turn.
    #
    def call_update
      p_update_procs.each { |p| p.call }
    end

    # Execute the before_player_update blocks for each player. This method is
    # typically called by the Plot while updating a turn, immediately before
    # processing player input.
    #
    def call_before_player_update
      p_players.each { |player|
        player.flush
        p_before_player_update_procs.each { |block| block.call player }
      }
    end

    # Execute the on_player_ready blocks for each player. This method is
    # typically called by the Plot while beginning a turn, immediately after
    # the on_ready blocks.
    #
    def call_player_ready
      p_players.each { |player|
        unless player.next_scene.nil?
          player.cue player.next_scene
        end
        player.cue default_scene if player.scene.nil?
        #player.prepare nil
        #player.cue this_scene #unless player.scene.class == this_scene
        p_player_ready_procs.each { |block| block.call player }
      }
    end

    # Execute the on_player_update blocks for each player. This method is
    # typically called by the Plot while ending a turn, immediately before the
    # on_ready blocks.
    #
    def call_player_update
      p_players.each { |player|
        p_player_update_procs.each { |block| block.call player }
      }
    end

    def p_ready_procs
      @p_ready_procs ||= []
    end

    def p_update_procs
      @p_update_procs ||= []
    end

    def p_before_player_update_procs
      @p_before_player_update_procs ||= []
    end

    def p_player_ready_procs
      @p_player_ready_procs ||= []
    end

    def p_player_update_procs
      @p_player_update_procs ||= []
    end
  end

end
