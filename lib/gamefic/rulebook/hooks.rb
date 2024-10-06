# frozen_string_literal: true

module Gamefic
  class Rulebook
    # A collection of hooks that can be executed before and after an action.
    #
    class Hooks
      attr_reader :before_actions

      attr_reader :after_actions

      attr_reader :before_commands

      attr_reader :after_commands

      def initialize
        @before_actions = []
        @after_actions = []
        @before_commands = []
        @after_commands = []
      end

      def freeze
        super
        @before_actions.freeze
        @after_actions.freeze
        self
      end

      def before_action narrative, *verbs, &block
        Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`before_action` is deprecated. Use `before_command` instead."
        before_actions.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def after_action narrative, *verbs, &block
        Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`after_action` is deprecated. Use `after_command` instead."
        after_actions.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def before_command narrative, *verbs, &block
        before_commands.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def after_command narrative, *verbs, &block
        after_commands.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def empty?
        [before_actions, after_actions, before_commands, after_commands].all?(&:empty?)
      end

      def run_before action
        run_action_hooks action, before_actions
        run_command_hooks action.actor, before_commands
      end

      def run_after action
        run_action_hooks action, after_actions
        run_command_hooks action.actor, after_commands
      end

      private

      def run_action_hooks action, hooks
        hooks.each do |hook|
          break if action.cancelled?

          next unless hook.match?(action.verb)

          hook.callback.run action
        end
      end

      def run_command_hooks actor, hooks
        hooks.each do |hook|
          break if actor.cancelled?

          next unless hook.match?(actor.command.verb)

          hook.callback.run actor, actor.command
        end
      end
    end
  end
end
