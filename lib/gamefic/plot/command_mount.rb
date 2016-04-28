require 'gamefic/action'

module Gamefic

  module Plot::CommandMount
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
      act = self.action(command, *queries, &proc)
      act.meta = true
      act
    end
    def action(command, *queries, &proc)
      Action.new(self, command, *queries, &proc)
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
      self.action(command, *queries, &proc)
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
      xlate command, translation
    end
    def syntax(*args)
      xlate(*args)
    end
    def xlate(*args)
      syn = Syntax.new(self, *args)
      syn
    end
    def commandwords
      words = Array.new
      syntaxes.each { |s|
        word = s.first_word
        words.push(word) if !word.nil?
      }
      words.uniq
    end
  end
  
end
