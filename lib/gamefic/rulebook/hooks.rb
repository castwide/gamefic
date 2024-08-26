# frozen_string_literal: true

module Gamefic
  class Rulebook
    # A collection of hooks that can be executed before and after an action.
    #
    class Hooks
      attr_reader :before_actions

      attr_reader :after_actions

      def initialize
        @before_actions = []
        @after_actions = []
      end

      def freeze
        super
        @before_actions.freeze
        @after_actions.freeze
        self
      end

      def before_action narrative, *verbs, &block
        before_actions.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def after_action narrative, *verbs, &block
        after_actions.push Action::Hook.new(verbs, Callback.new(narrative, block))
      end

      def empty?
        before_actions.empty? && after_actions.empty?
      end

      def run_before action
        run_action_hooks action, before_actions
      end

      def run_after action
        run_action_hooks action, after_actions
      end

      private

      def run_action_hooks action, hooks
        hooks.each do |hook|
          break if action.cancelled?

          next unless hook.match?(action.verb)

          hook.callback.run action
        end
      end
    end
  end
end
