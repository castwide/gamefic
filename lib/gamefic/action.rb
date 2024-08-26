# frozen_string_literal: true

module Gamefic
  # The handler for executing responses for a provided actor and array of
  # arguments. It's also responsible for executing before_action and
  # after_action hooks if necessary.
  #
  class Action
    include Logging

    # Hooks are blocks of code that get executed before or after an actor
    # performs an action. A before action hook is capable of cancelling the
    # action's performance.
    #
    class Hook
      # @param [Array<Symbol>]
      attr_reader :verbs

      # @param [Callback]
      attr_reader :callback

      def initialize verbs, callback
        @verbs = verbs
        @callback = callback
      end

      def match?(input)
        verbs.empty? || verbs.include?(input)
      end
    end

    # @return [Active]
    attr_reader :actor

    # @return [Array]
    attr_reader :arguments

    # @return [Response]
    attr_reader :response

    # @param actor [Active]
    # @param arguments [Array]
    # @param response [Response]
    def initialize actor, arguments, response
      @actor = actor
      @arguments = arguments
      @response = response
    end

    # @return [self]
    def execute
      return self if cancelled? || executed?

      @executed = true
      response.execute actor, *arguments
      self
    end

    # True if the response has been executed. False typically means that the
    # #execute method has not been called or the action was cancelled in a
    # before_action hook.
    #
    def executed?
      @executed ||= false
    end

    # Cancel an action. This method can be called in an action hook to
    # prevent subsequent hooks and/or the action itself from being executed.
    #
    def cancel
      @cancelled = true
    end

    def cancelled?
      @cancelled ||= false
    end

    def verb
      response.verb
    end

    def narrative
      response.narrative
    end

    def meta?
      response.meta?
    end
  end
end
