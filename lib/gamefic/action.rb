# frozen_string_literal: true

module Gamefic
  # The handler for executing responses for a provided actor and array of
  # arguments. It's also responsible for executing before_action and
  # after_action hooks if necessary.
  #
  class Action
    include Logging

    Hook = Struct.new(:verb, :block)

    # @return [Active]
    attr_reader :actor

    # @return [Array]
    attr_reader :arguments

    # @return [Response]
    attr_reader :response

    # @param actor [Active]
    # @param arguments [Array]
    # @param response [Response]
    # @param with_hooks [Boolean]
    def initialize actor, arguments, response, with_hooks = false
      @actor = actor
      @arguments = arguments
      @response = response
      @with_hooks = with_hooks
    end

    def execute
      return if cancelled?

      run_before_actions
      return if cancelled?

      # log_executing 'response', response.block.source_location
      # response.block[actor, *arguments]
      response.execute actor, *arguments
      @executed = true
      run_after_actions
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

    def meta?
      response.meta?
    end

    def with_hooks?
      @with_hooks
    end

    private

    def run_before_actions
      return unless with_hooks? && !cancelled?

      actor.playbooks.flat_map { |pb| pb.run_before_actions self }
    end

    def run_after_actions
      return unless with_hooks? && !cancelled?

      actor.playbooks.flat_map { |pb| pb.run_after_actions self }
    end
  end
end
