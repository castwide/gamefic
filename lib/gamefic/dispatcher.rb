module Gamefic
  class Dispatcher
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
          next if cmd.verb != action.verb
          instance = action.attempt(actor, cmd.arguments)
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

    def self.dispatch actor, command
      group = actor.playbooks.reverse.map { |p| p.dispatch(actor, command) }
      dispatcher = Dispatcher.new(actor)
      group.each { |d| dispatcher.merge d }
      dispatcher
    end

    protected

    attr_reader :actor

    attr_reader :commands

    attr_reader :actions

    private

    def validate_playbook playbook, action
      playbook.validators.all? { |v| v.call(actor, action.verb, action.parameters) != false }
    end
  end
end
