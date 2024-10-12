# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Hooks
      # @deprecated
      def before_action(*verbs, &block)
        before_actions.push(proc do |action|
          instance_exec(action, &block) if verbs.empty? || verbs.include?(action.verb)
        end)
      end

      # @deprecated
      def after_action(*verbs, &block)
        after_actions.push(proc do |action|
          instance_exec(action, &block) if verbs.empty? || verbs.include?(action.verb)
        end)
      end

      def before_command(*verbs, &block)
        before_commands.push(proc do |actor, command|
          instance_exec(actor, command, &block) if verbs.empty? || verbs.include?(command.verb)
        end)
      end

      def after_command(*verbs, &block)
        after_commands.push(proc do |actor, command|
          instance_exec(actor, command, &block) if verbs.empty? || verbs.include?(command.verb)
        end)
      end

      def on_ready(&block)
        ready_blocks.push block
      end

      def on_player_ready(&block)
        ready_blocks.push(proc { players.each { |player| block[player] } })
      end

      def on_update(&block)
        update_blocks.push block
      end

      def on_player_update(&block)
        update_blocks.push(proc { players.each { |player| block[player] } })
      end

      def on_player_output(&block)
        player_output_blocks.push(proc { players.each { |player| block[player] } })
      end

      def on_player_conclude(&block)
        player_conclude_blocks.push(proc { players.each { |player| block[player] } })
      end

      def before_actions
        @before_actions ||= []
      end

      def after_actions
        @after_actions ||= []
      end

      def before_commands
        @before_commands ||= []
      end

      def after_commands
        @after_commands ||= []
      end

      def ready_blocks
        @ready_blocks ||= []
      end

      def update_blocks
        @update_blocks ||= []
      end

      def player_output_blocks
        @player_output_blocks ||= []
      end

      def player_conclude_blocks
        @player_conclude_blocks ||= []
      end
    end
  end
end
