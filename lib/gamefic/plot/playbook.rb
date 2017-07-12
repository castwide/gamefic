module Gamefic
  # A collection of rules for performing commands in plots.
  #
  class Playbook
    def initialize commands: {}, syntaxes: [], validators: [], disambiguator: nil
      @commands = commands
      @syntaxes = syntaxes
      @validators = validators
      @disambiguator = disambiguator
    end

    # An array of available syntaxes.
    #
    # @return [Array<Gamefic::Syntax>]
    def syntaxes
      @syntaxes
    end

    # An array of available actions.
    #
    # @return [Array<Gamefic::Action>]
    def actions
      @commands.values.flatten
    end

    # An array of recognized verbs.
    #
    # @return [Array<Symbol>]
    def verbs
      @commands.keys
    end

    # An array of defined validators.
    #
    # @return [Array<Proc>]
    def validators
      @validators
    end

    def disambiguator
      @disambiguator ||= Action.new(nil, Query::Base.new) do |actor, entities|
        definites = []
        entities.each { |entity|
          definites.push entity.definitely
        }
        actor.tell "I don't know which you mean: #{definites.join_or}."
      end
    end

    #def disambiguate &block
    #  @disambiguator = Action.new(nil, Query::Base.new, &block)
    #  @disambiguator.meta = true
    #  @disambiguator
    #end

    # Add a block that determines whether an action can be executed.
    #
    def validate &block
      @validators.push block
    end

    # Get an Array of all Actions associated with the specified verb.
    #
    # @param verb [Symbol] The Symbol for the verb (e.g., :go or :look)
    # @return [Array<Action>] The verb's associated Actions
    def actions_for verb
      @commands[verb] || []
    end

    # Create an Action that responds to a command.
    # An Action uses the command argument to identify the imperative verb that
    # triggers the action.
    # It can also accept queries to tokenize the remainder of the input and
    # filter for particular entities or properties.
    # The block argument contains the code to be executed when the input
    # matches all of the Action's criteria (i.e., verb and queries).
    #
    # @example A simple Action.
    #   respond :salute do |actor|
    #     actor.tell "Hello, sir!"
    #   end
    #   # The command "salute" will respond "Hello, sir!"
    #
    # @example An Action that accepts a Character
    #   respond :salute, Use.visible(Character) do |actor, character|
    #     actor.tell "#{The character} returns your salute."
    #   end
    #
    # @param verb [Symbol] An imperative verb for the command
    # @param queries [Array<Query::Base>] Filters for the command's tokens
    # @yieldparam [Gamefic::Character]
    # @return [Gamefic::Action]
    def respond(verb, *queries, &proc)
      act = Action.subclass verb, *queries, order_key: raise_order_key, &proc
      add_action act
      act
    end

    # Create a Meta Action that responds to a command.
    # Meta Actions are very similar to standard Actions, except the Plot
    # understands them to be commands that operate above and/or outside of the
    # actual game world. Examples of Meta Actions are commands that report the
    # player's current score, save and restore saved games, or list the game's
    # credits.
    #
    # @example A simple Meta Action
    #   meta :credits do |actor|
    #     actor.tell "This game was written by John Smith."
    #   end
    #
    # @param verb [Symbol] An imperative verb for the command
    # @param queries [Array<Query::Base>] Filters for the command's tokens
    # @yieldparam [Gamefic::Character]
    def meta(verb, *queries, &proc)
      act = Action.subclass verb, *queries, meta: true, &proc
      add_action act
      act
    end

    # Create an alternate Syntax for an Action.
    # The command and its translation can be parameterized.
    #
    # @example Create a synonym for the Inventory Action.
    #   interpret "catalogue", "inventory"
    #   # The command "catalogue" will be translated to "inventory"
    #
    # @example Create a parameterized synonym for the Look Action.
    #   interpret "scrutinize :entity", "look :entity"
    #   # The command "scrutinize chair" will be translated to "look chair"
    #
    # @param input [String] The format of the original command
    # @param translation [String] The format of the translated command
    # @return [Syntax] the Syntax object
    def interpret(input, translation)
      syn = Syntax.new(input, translation)
      add_syntax syn
      syn
    end

    # Get an array of actions, derived from the specified command, that the
    # actor can potentially execute.
    # The command can either be a single string (e.g., "examine book") or a
    # list of tokens (e.g., :examine, @book).
    #
    # @return [Array<Gamefic::Action>]
    def dispatch(actor, *command)
      result = []
      if command.length > 1
        result.concat dispatch_from_params(actor, command[0], command[1..-1])
      end
      if result.empty?
        result.concat dispatch_from_string(actor, command.join(' '))
      end
      result
    end

    # Get an array of actions, derived from the specified command, that the
    # actor can potentially execute.
    # The command should be a plain-text string, e.g., "examine the book."
    #
    # @return [Array<Gamefic::Action>]
    def dispatch_from_string actor, text
      result = []
      commands = Syntax.tokenize(text, syntaxes)
      commands.each { |c|
        available = actions_for(c.verb)
        available.each { |a|
          next if a.hidden?
          o = a.attempt(actor, c.arguments)
          result.unshift o unless o.nil?
        }
      }
      sort_and_reduce_actions result
    end

    # Get an array of actions, derived from the specified verb and params,
    # that the actor can potentially execute.
    #
    # @return [Array<Gamefic::Action>]
    def dispatch_from_params actor, verb, params
      result = []
      available = actions_for(verb)
      available.each { |a|
        result.unshift a.new(actor, params) if a.valid?(actor, params)
      }
      sort_and_reduce_actions result
    end

    # Duplicate the playbook.
    # This method will duplicate the commands hash and the syntax array so
    # the new playbook can be modified without affecting the original.
    #
    # @return [Playbook]
    def dup
      Playbook.new commands: @commands.dup, syntaxes: @syntaxes.dup
    end

    def freeze
      @commands.freeze
      @syntaxes.freeze
    end

    private

    def add_action(action)
      @commands[action.verb] ||= []
      @commands[action.verb].push action
      #@commands[action.verb].uniq!
      #@commands[action.verb].sort! { |a, b|
      #  b.rank <=> a.rank
      #}
      generate_default_syntax action
    end

    def generate_default_syntax action
      user_friendly = action.verb.to_s.gsub(/_/, ' ')
      args = []
      used_names = []
      action.queries.each { |c|
        num = 1
        new_name = ":var"
        while used_names.include? new_name
          num = num + 1
          new_name = ":var#{num}"
        end
        used_names.push new_name
        user_friendly += " #{new_name}"
        args.push new_name
      }
      add_syntax Syntax.new(user_friendly.strip, "#{action.verb} #{args.join(' ')}")
    end

    def add_syntax syntax
      if @commands[syntax.verb] == nil
        raise "No actions exist for \"#{syntax.verb}\""
      end
      @syntaxes.unshift syntax
      @syntaxes.uniq!
      @syntaxes.sort! { |a, b|
        if a.token_count == b.token_count
          # For syntaxes of the same length, length of action takes precedence
          b.first_word <=> a.first_word
        else
          b.token_count <=> a.token_count
        end
      }
    end

    def sort_and_reduce_actions arr
      arr.sort { |a,b|
        if a.rank == b.rank
          b.order_key <=> a.order_key
        else
          b.rank <=> a.rank
        end
      }.uniq{|a| a.class}
    end

    def raise_order_key
      @@order_key ||= 0
      tmp = @@order_key
      @@order_key += 1
      tmp
    end
  end
end
