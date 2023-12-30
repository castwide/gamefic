# frozen_string_literal: true

module Gamefic
  class Rulebook
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

      # @return [Proc]
      def on_ready &block
        @ready_blocks.push block
      end

      # @yieldparam [Actor]
      # @return [Proc]
      def on_player_ready &block
        @ready_blocks.push(proc do
          players.each { |plyr| block.call plyr }
        end)
      end

      def on_update &block
        @update_blocks.push block
      end

      def on_player_update &block
        @update_blocks.push(proc do
          players.each { |plyr| block.call plyr }
        end)
      end

      # @return [Proc]
      def on_conclude &block
        @conclude_blocks.push block
      end

      # @yieldparam [Actor]
      # @return [Proc]
      def on_player_conclude &block
        @player_conclude_blocks.push block
      end

      # @yieldparam [Actor]
      # @yieldparam [Hash]
      # @return [Proc]
      def on_player_output &block
        @player_output_blocks.push block
      end
    end
  end
end
