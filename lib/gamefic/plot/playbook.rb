module Gamefic

  class Plot
    class Playbook
      def initialize commands: {}, syntaxes: [], validators: [], disambiguator: nil
        @commands = commands
        @syntaxes = syntaxes
        @validators = validators
        @disambiguator = disambiguator
      end

      def syntaxes
        @syntaxes
      end

      def actions
        @commands.values.flatten
      end

      def verbs
        @commands.keys
      end

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

      def disambiguate &block
        @disambiguator = Action.new(nil, Query::Base.new, &block)
        @disambiguator.meta = true
        @disambiguator
      end

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
      # @param command [Symbol] An imperative verb for the command
      # @param *queries [Array<Query::Base>] Queries to filter the command's tokens
      # @yieldparam [Character]
      def respond(command, *queries, &proc)
        act = Action.new(command, *queries, &proc)
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
      # @param command [Symbol] An imperative verb for the command
      # @param *queries [Array<Query::Base>] Queries to filter the command's tokens
      # @yieldparam [Character]
      def meta(command, *queries, &proc)
        act = respond(command, *queries, &proc)
        act.meta = true
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
      # @param command [String] The format of the original command
      # @param translation [String] The format of the translated command
      # @return [Syntax] the Syntax object
      def interpret(*args)
        syn = Syntax.new(*args)
        add_syntax syn
        syn
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
        @commands[action.verb].unshift action
        @commands[action.verb].sort! { |a, b|
          if a.specificity == b.specificity
            # Newer action takes precedence
            b.order_key <=> a.order_key
          else
            # Higher specificity takes precedence
            b.specificity <=> a.specificity
          end
        }
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
        @syntaxes.uniq
        @syntaxes.sort! { |a, b|
          if a.token_count == b.token_count
            # For syntaxes of the same length, length of action takes precedence
            b.first_word <=> a.first_word
          else
            b.token_count <=> a.token_count
          end
        }
      end
    end
  end

end
