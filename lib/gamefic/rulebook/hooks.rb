# frozen_string_literal: true

module Gamefic
  class Rulebook
    # A collection of hooks that can be executed before and after an action.
    #
    class Hooks
      attr_reader :before_actions

      attr_reader :after_actions

      def initialize stage
        @stage = stage
        @before_actions = []
        @after_actions = []
      end

      def freeze
        super
        @before_actions.freeze
        @after_actions.freeze
        self
      end

      def run_before_actions action
        run_action_hooks action, before_actions
      end

      def run_after_actions action
        run_action_hooks action, after_actions
      end

      def empty?
        before_actions.empty? && after_actions.empty?
      end

      private

      def run_action_hooks action, hooks
        hooks.each do |hook|
          break if action.cancelled?

          next unless hook.verb.nil? || hook.verb == action.verb

          @stage.call action, &hook.block
        end
      end
    end
  end
end
