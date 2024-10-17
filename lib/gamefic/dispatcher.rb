# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    # @return [Actor]
    attr_reader :actor

    # @return [Command]
    attr_reader :command

    # @param actions [Array<Action>]
    def initialize(actions)
      @actions = actions
      @actor = actions.first&.actor
      @command = actions.first&.command
    end

    # Start executing actions in the dispatcher.
    #
    # @return [Action, nil]
    def execute
      return if @action

      Gamefic.logger.info "Dispatching #{actor.inspect} #{command.inspect}"
      @action = next_action
      return unless @action

      actor.narratives.before_commands.each { |blk| blk[actor, command] }
      return if command.cancelled?

      @action.execute
      actor.narratives.after_commands.each { |blk| blk[actor, command] }
      @action
    end

    # Execute the next available action.
    #
    # Actors should run #execute first.
    #
    # @return [Action, nil]
    def proceed
      return unless @action
      return if command.cancelled?

      next_action&.execute
    end

    def cancel
      command&.cancel
    end

    def cancelled?
      command&.cancelled?
    end

    # @param actionable [#to_actions]
    def self.dispatch(actionable)
      new(actionable.to_actions)
    end

    private

    attr_reader :actions

    # @return [Action, nil]
    def next_action
      while (action = actions.shift)
        return action if action.actor == actor && action.valid?
      end
    end
  end
end
