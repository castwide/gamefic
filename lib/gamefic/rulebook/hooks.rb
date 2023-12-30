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
    end
  end
end
