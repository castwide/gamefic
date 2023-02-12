# frozen_string_literal: true

module Gamefic
  # The action selector for character commands.
  #
  class Dispatcher
    # @param actor [Actor]
    # @param commands [Array<Command>]
    # @param actions [Array<Action>]
    def initialize actor, commands = [], actions = []
      @actor = actor
      @commands = commands
      @actions = actions
      @started = false
    end

    # @param dispatcher [Dispatcher]
    # @return [void]
    def merge dispatcher
      commands.concat dispatcher.commands
      actions.concat dispatcher.actions
    end

    # Get the next executable action.
    #
    # @return [Action, nil]
    def next
      instance = nil
      while instance.nil? && !@actions.empty?
        action = actions.shift
        commands.each do |cmd|
          instance = action.attempt(actor, cmd, !@started)
          if instance
            @started = true
            break
          end
        end
      end
      instance
    end

    # @param actor [Active]
    # @param command [String]
    # @return [Dispatcher]
    def self.dispatch actor, command
      group = actor.playbooks.reverse.map { |p| p.dispatch(actor, command) }
      dispatcher = Dispatcher.new(actor)
      group.each { |d| dispatcher.merge d }
      dispatcher
    end

    # @param actor [Active]
    # @param verb [Symbol]
    # @param params [Array<Object>]
    # @return [Dispatcher]
    def self.dispatch_from_params actor, verb, params
      group = actor.playbooks.reverse.map { |p| p.dispatch_from_params(actor, verb, params) }
      dispatcher = Dispatcher.new(actor)
      group.each { |d| dispatcher.merge d }
      dispatcher
    end

    protected

    # @return [Actor]
    attr_reader :actor

    # @return [Array<Command>]
    attr_reader :commands

    # @return [Array<Action>]
    attr_reader :actions
  end
end
