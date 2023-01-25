require 'set'

module Gamefic
  module World
    # A collection of rules for performing commands.
    #
    class Playbook
      # An array of available syntaxes.
      #
      # @return [Array<Gamefic::Syntax>]
      attr_reader :syntaxes

      # An array of blocks to execute before actions.
      #
      # @return [Array<Proc>]
      attr_reader :before_actions

      # An array of blocks to execute after actions.
      #
      # @return [Array<Proc>]
      attr_reader :after_actions

      # @param commands [Hash]
      # @param syntaxes [Array<Syntax>, Set<Syntax>]
      # @param before_actions [Array]
      # @param after_actions [Array]
      def initialize commands: {}, syntaxes: [], before_actions: [], after_actions: []
        @commands = commands
        @syntax_set = syntaxes.to_set
        sort_syntaxes
        @before_actions = before_actions
        @after_actions = after_actions
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

      # Add a proc to be evaluated before a character executes an action.
      #
      # @yieldparam [Gamefic::Action]
      def before_action &block
        @before_actions.push block
      end
      alias validate before_action

      # Add a proc to be evaluated after a character executes an action.
      #
      # @yieldparam [Gamefic::Action]
      def after_action &block
        @after_actions.push block
      end

      # Get an Array of all Actions associated with the specified verb.
      #
      # @param verb [Symbol] The Symbol for the verb (e.g., :go or :look)
      # @return [Array<Class<Action>>] The verb's associated Actions
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
      # @yieldparam [Gamefic::Actor]
      # @return [Class<Gamefic::Action>]
      def respond(verb, *queries, &proc)
        act = Action.subclass verb, *queries, &proc
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
      # @yieldparam [Gamefic::Actor]
      # @return [Class<Gamefic::Action>]
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

      # Get a Dispatcher to select actions that can potentially be executed
      # from the specified command string.
      #
      # @param actor [Actor]
      # @param text [String]
      # @return [Dispatcher]
      def dispatch(actor, text)
        commands = Syntax.tokenize(text, actor.syntaxes)
        actions = commands.flat_map { |cmd| actions_for(cmd.verb).reject(&:hidden?) }
        Dispatcher.new(actor, commands, sort_and_reduce_actions(actions))
      end

      # Get an array of actions, derived from the specified verb and params,
      # that the actor can potentially execute.
      #
      # @return [Array<Gamefic::Action>]
      def dispatch_from_params actor, verb, params
        available = actions_for(verb)
        Dispatcher.new(actor, [Command.new(verb, params)], sort_and_reduce_actions(available))
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
        generate_default_syntax action
      end

      def generate_default_syntax action
        user_friendly = action.verb.to_s.gsub(/_/, ' ')
        args = []
        used_names = []
        action.queries.each do |_c|
          num = 1
          new_name = ":var"
          while used_names.include? new_name
            num += 1
            new_name = ":var#{num}"
          end
          used_names.push new_name
          user_friendly += " #{new_name}"
          args.push new_name
        end
        add_syntax Syntax.new(user_friendly.strip, "#{action.verb} #{args.join(' ')}") unless action.verb.to_s.start_with?('_')
      end

      def add_syntax syntax
        raise "No actions exist for \"#{syntax.verb}\"" if @commands[syntax.verb].nil?
        sort_syntaxes if @syntax_set.add?(syntax)
      end

      def sort_and_reduce_actions arr
        arr.sort_by.with_index { |a, i| [a.rank, i] }.reverse.uniq
      end

      def sort_syntaxes
        @syntaxes = @syntax_set.sort do |a, b|
          if a.token_count == b.token_count
            # For syntaxes of the same length, sort first word
            b.first_word <=> a.first_word
          else
            b.token_count <=> a.token_count
          end
        end
      end
    end
  end
end
