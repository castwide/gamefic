# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating event callbacks.
    #
    module Events
      # Add a block to be executed on preparation of every turn.
      #
      # @example Increment a turn counter
      #   turn = 0
      #   on_ready do
      #     turn += 1
      #   end
      #
      def on_ready &block
        rulebook.events.on_ready(Callback.new(self, block))
      end

      # Add a block to be executed for each player at the beginning of a turn.
      #
      # @example Tell the player how many turns they've played.
      #   on_player_ready do |player|
      #     player[:turns] ||= 1
      #     player.tell "Turn #{player[:turns]}"
      #     player[:turns] += 1
      #   end
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_ready &block
        wrapper = proc do
          players.each { |player| block[player] }
        end
        on_ready &wrapper
      end

      # Add a block to be executed after the Plot is finished updating a turn.
      #
      def on_update &block
        rulebook.events.on_update(Callback.new(self, block))
      end

      # Add a block to be executed for each player at the end of a turn.
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_update &block
        wrapper = proc do
          players.each { |player| block[player] }
        end
        on_update &wrapper
      end

      def on_conclude &block
        rulebook.events.on_conclude(Callback.new(self, block))
      end

      # @yieldparam [Actor]
      # @return [Proc]
      def on_player_conclude &block
        rulebook.events.on_player_conclude(Callback.new(self, block))
      end

      # @yieldparam [Actor]
      # @yieldparam [Hash]
      # @return [Proc]
      def on_player_output &block
        rulebook.events.on_player_output Callback.new(self, block)
      end
    end
  end
end
