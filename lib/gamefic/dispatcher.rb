# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    # @param actionable [#to_actions]
    def initialize(actionable)
      @actions = actionable.to_actions
                           .sort_by.with_index do |action, idx|
                             [-action.substantiality, -action.strictness, -action.precision, idx]
                           end
      @actor = actions.first&.actor
      @command = actions.first&.command
    end

    # Start executing actions in the dispatcher.
    #
    # @return [Command, nil]
    def execute
      return if @action

      Gamefic.logger.info "Dispatching #{actor.inspect} #{command.inspect}"
      @action = actions.shift
      return unless @action

      actor.narratives.before_commands.each { |blk| blk[actor, command] }
      return if command.cancelled?

      @action.execute
      actor.narratives.after_commands.each { |blk| blk[actor, command] }
      command.freeze
    end

    # Execute the next available action.
    #
    # Actors should run #execute first.
    #
    # @return [Action, nil]
    def proceed
      return unless @action
      return if command.cancelled?

      actions.shift&.execute
    end

    def cancel
      command&.cancel
    end

    private

    # @return [Actor]
    attr_reader :actor

    # @return [Command]
    attr_reader :command

    # @return [Array<Action>]
    attr_reader :actions
  end
end
