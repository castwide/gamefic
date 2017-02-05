require 'gamefic/action'

module Gamefic

  module Plot::CommandMount
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
      playbook.respond(command, *queries, &proc)
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
      playbook.meta command, *queries, &proc
    end

    # @deprecated
    def action(command, *queries, &proc)
      respond command, *queries, &proc
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
    def interpret command, translation
      playbook.interpret command, translation
    end

    # @deprecated
    def xlate command, translation
      interpret command, translation
    end

    # Get an Array of available verbs.
    # If the to_s parameter is true, convert Symbols to Strings.
    #
    # @return [Array<Symbol|String>]
    def verbs to_s: false
      to_s ? playbook.verbs.map { |v| v.to_s } : playbook.verbs
    end

    # Get an Array of all Actions defined in the Plot.
    #
    # @return [Array<Action>]
    def actions
      playbook.actions
    end
  end
  
end
