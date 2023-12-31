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

      def before_action verb = nil, &hook
        before_actions.push Action::Hook.new(verb, hook)
      end

      def after_action verb = nil, &hook
        after_actions.push Action::Hook.new(verb, hook)
      end

      def empty?
        before_actions.empty? && after_actions.empty?
      end

      def run_before action, narrative
        run_action_hooks action, narrative, before_actions
      end

      def run_after action, narrative
        run_action_hooks action, narrative, after_actions
      end

      private

      def run_action_hooks action, narrative, hooks
        hooks.each do |hook|
          break if action.cancelled?

          next unless hook.match?(action.verb)

          Stage.run(narrative) { hook.block.call(action) }
        end
      end
    end
  end
end
