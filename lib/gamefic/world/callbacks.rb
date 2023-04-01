module Gamefic
  module World
    module Callbacks
      include Logging

      # Add a block to be executed on preparation of every turn.
      #
      # @example Increment a turn counter
      #   turn = 0
      #   on_ready do
      #     turn += 1
      #   end
      #
      def on_ready &block
        ready_procs.push block
      end

      # Add a block to be executed after the Plot is finished updating a turn.
      #
      def on_update &block
        update_procs.push block
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
      # @yieldparam [Gamefic::Actor]
      def on_player_ready &block
        player_ready_procs.push block
      end

      # Add a block to be executed for each player before an update.
      #
      # @yieldparam[Gamefic::Actor]
      def before_player_update &block
        before_player_update_procs.push block
      end

      # Add a block to be executed for each player at the end of a turn.
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_update &block
        player_update_procs.push block
      end

      def ready_procs
        @ready_procs ||= []
      end

      def update_procs
        @update_procs ||= []
      end

      def player_ready_procs
        @player_ready_procs ||= []
      end

      def before_player_update_procs
        @before_player_update_procs ||= []
      end

      def player_update_procs
        @player_update_procs ||= []
      end

      private

      # Execute the on_ready blocks. This method is typically called by the
      # Plot while beginning a turn.
      #
      def call_ready
        ready_procs.each { |p| p.call }
      end

      # Execute the on_update blocks. This method is typically called by the
      # Plot while ending a turn.
      #
      def call_update
        update_procs.each { |p| p.call }
      end

      # Execute the before_player_update blocks for each player. This method is
      # typically called by the Plot while updating a turn, immediately before
      # processing player input.
      #
      def call_before_player_update
        players.each { |player|
          player.flush
          before_player_update_procs.each { |block| block.call player }
        }
      end

      # Execute the on_player_ready blocks for each player. This method is
      # typically called by the Plot while beginning a turn, immediately after
      # the on_ready blocks.
      #
      def call_player_ready
        players.each { |player|
          player_ready_procs.each { |block| block.call player }
        }
      end

      # Execute the on_player_update blocks for each player. This method is
      # typically called by the Plot while ending a turn, immediately before the
      # on_ready blocks.
      #
      def call_player_update
        players.each { |player|
          player_update_procs.each { |block| block.call player }
        }
      end
    end
  end
end
