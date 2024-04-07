# frozen_string_literal: true

module Gamefic
  class Rulebook
    # Blocks of code to be executed for various narrative events, such as
    # on_ready and on_update.
    #
    class Events
      attr_reader :player_output_blocks

      attr_reader :player_conclude_blocks

      attr_reader :ready_blocks

      attr_reader :update_blocks

      attr_reader :conclude_blocks

      def initialize
        @ready_blocks = []
        @update_blocks = []
        @conclude_blocks = []
        @player_conclude_blocks = []
        @player_output_blocks = []
      end

      def empty?
        [player_output_blocks, player_conclude_blocks, ready_blocks, update_blocks, conclude_blocks].all?(&:empty?)
      end

      def freeze
        super
        instance_variables.each { |k| instance_variable_get(k).freeze }
        self
      end

      # @return [void]
      def on_ready &block
        @ready_blocks.push block
      end

      # @yieldparam [Actor]
      # @return [void]
      def on_player_ready &block
        @ready_blocks.push(proc do
          players.each { |plyr| instance_exec plyr, &block }
        end)
      end

      def on_update &block
        @update_blocks.push block
      end

      def on_player_update &block
        @update_blocks.push(proc do
          players.each { |plyr| instance_exec plyr, &block }
        end)
      end

      # @return [void]
      def on_conclude &block
        @conclude_blocks.push block
      end

      # @yieldparam [Actor]
      # @return [void]
      def on_player_conclude &block
        @player_conclude_blocks.push block
      end

      # @yieldparam [Actor]
      # @yieldparam [Hash]
      # @return [void]
      def on_player_output &block
        @player_output_blocks.push block
      end
    end
  end
end
