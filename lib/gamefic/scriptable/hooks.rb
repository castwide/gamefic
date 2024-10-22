# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Hooks
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
        ready_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
      end

      def on_update(&block)
        update_blocks.push block
      end

      def on_player_update(&block)
        update_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
      end

      def on_player_output(&block)
        player_output_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
      end

      def on_player_conclude(&block)
        player_conclude_blocks.push(proc { players.each { |player| instance_exec(player, &block) } })
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
