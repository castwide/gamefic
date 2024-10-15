# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    # @return [Command]
    attr_reader :command

    # @param actor [Actor]
    # @param command [Command]
    def initialize actor, command
      @actor = actor
      @command = command
      @action = nil
      Gamefic.logger.info "Dispatching #{command.inspect}"
    end

    # Start executing actions in the dispatcher.
    #
    # @return [Action, nil]
    def execute
      return if @action

      @action = next_action
      return unless @action

      actor.narratives.flat_map(&:before_actions).each { |blk| blk[@action] }
      actor.narratives.flat_map(&:before_commands).each { |blk| blk[@actor, @command] }
      return if @action.cancelled?

      @action.execute
      actor.narratives.flat_map(&:after_actions).each { |blk| blk[@action] }
      actor.narratives.flat_map(&:after_commands).each { |blk| blk[@actor, @command] }
      @action
    end

    # Execute the next available action.
    #
    # Actors should run #execute first.
    #
    # @return [Action, nil]
    def proceed
      return unless @action
      return if @action.cancelled?

      next_action&.execute
    end

    def cancel
      @action&.cancel
    end

    def cancelled?
      @action&.cancelled?
    end

    # @param actor [Active]
    # @param input [String]
    # @return [Dispatcher]
    def self.dispatch actor, input
      new(actor, Command.compose(actor, input))
    end

    # @param actor [Active]
    # @param verb [Symbol]
    # @param params [Array<Object>]
    # @return [Dispatcher]
    def self.dispatch_from_params actor, verb, params
      command = Command.new(verb, params)
      new(actor, command)
    end

    protected

    # @return [Actor]
    attr_reader :actor

    # @return [Array<Response>]
    def responses
      @responses ||= actor.narratives.flat_map { |narr| narr.responses_for(command.verb) }
    end

    private

    # @return [Action, nil]
    def next_action
      while (response = responses.shift)
        next if response.queries.length < @command.arguments.length

        return Action.new(actor, @command, response) if response.accept?(actor, @command)
      end
    end
  end
end
