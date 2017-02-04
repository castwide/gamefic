module Gamefic

  class Plot::Playbook
    def initialize commands, syntaxes
      @commands = commands
      @syntaxes = syntaxes
    end

    def commands
      @commands.clone
    end

    def syntaxes
      @syntaxes.clone
    end

    def actions
      @commands.values.flatten
    end

    # Get an Array of all Actions associated with the specified verb.
    #
    # @param verb [Symbol] The Symbol for the verb (e.g., :go or :look)
    # @return [Array<Action>] The verb's associated Actions
    def actions_with_verb(verb)
      commands[verb] || []
    end
  end

end
