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
    end

    def merge dispatcher
      commands.concat dispatcher.commands
      actions.concat dispatcher.actions
    end

    def next
      instance = nil
      while instance.nil? && !@actions.empty?
        action = actions.shift
        commands.each do |cmd|
          instance = action.attempt(actor, cmd)
          if instance
            unless instance.meta?
              actor.playbooks.reverse.each do |playbook|
                return nil unless validate_playbook(playbook, instance)
              end
            end
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

    private

    def validate_playbook playbook, action
      playbook.validators.all? { |v| v.call(actor, action.verb, action.parameters) != false }
    end
  end
end
