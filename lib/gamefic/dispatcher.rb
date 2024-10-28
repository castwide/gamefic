# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    # @param actionable [#to_actions]
    def initialize(actionable)
      @actions = Action.sort(actionable.to_actions)
    end

    # Start executing actions in the dispatcher.
    #
    # @return [Command, nil]
    def execute
      return if action || actions.empty?

      @action = actions.shift
      Gamefic.logger.info "Dispatching #{actor.inspect} #{command.inspect}"
      run_hooks_and_response
      command
    end

    # Execute the next available action.
    #
    # Actors should run #execute first.
    #
    # @return [Action, nil]
    def proceed
      return if !action || command.cancelled?

      actions.shift&.execute
    end

    def cancel
      command&.cancel
    end

    private

    # @return [Array<Action>]
    attr_reader :actions

    # @return [Action, nil]
    attr_reader :action

    # @return [Actor, nil]
    def actor
      action.actor
    end

    # @return [Command]
    def command
      action.command
    end

    def run_hooks(list)
      list.each do |blk|
        blk[actor, command]
        break if command.cancelled?
      end
    end

    def run_hooks_and_response
      run_hooks actor.narratives.before_commands
      command.freeze
      return if command.cancelled?

      action.execute
      run_hooks actor.narratives.after_commands
    end
  end
end
