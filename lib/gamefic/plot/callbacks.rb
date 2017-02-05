module Gamefic

  module Plot::Callbacks
    # Add a block to be executed on preparation of every turn.
    # Each on_ready block is executed once per turn, as opposed to
    # on_player_ready blocks, which are executed once for each player.
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
    # Each on_update block is executed once per turn, as opposed to
    # on_player_update blocks, which are executed once for each player.
    #
    def on_update &block
      p_update_procs.push block
    end

    def on_player_ready &block
      p_player_ready_procs.push block
    end

    def on_player_update &block
      p_player_update_procs.push block
    end

    def call_ready
      p_ready_procs.each { |p| p.call }
    end

    def call_update
      p_update_procs.each { |p| p.call }
    end

    def call_player_ready
      p_players.each { |player|
        this_scene = player.next_scene || player.scene
        player.prepare nil
        player.cue this_scene unless player.scene == this_scene
        p_player_ready_procs.each { |block| block.call player }
      }
    end

    def call_player_update
      p_players.each { |player|
        p_player_update_procs.each { |block| block.call player }
      }
    end

    private

    def p_ready_procs
      @p_ready_procs ||= []
    end

    def p_update_procs
      @p_update_procs ||= []
    end

    def p_player_ready_procs
      @p_player_ready_procs ||= []
    end

    def p_player_update_procs
      @p_player_update_procs ||= []
    end
  end

end
