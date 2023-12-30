# frozen_string_literal: true

require 'set'

module Gamefic
  # A class module that enables scripting.
  #
  # Narratives extend Scriptable to enable definition of scripts and seeds.
  # Modules can also be extended with Scriptable to make them includable to
  # other Scriptables.
  #
  # @example Include a scriptable module in a plot
  #   module MyScript
  #     extend Scriptable
  #
  #     script do
  #       respond :myscript do |actor|
  #         actor.tell "This command was added by MyScript"
  #       end
  #     end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     include MyScript
  #   end
  #
  module Scriptable
    # @return [Array<Block>]
    def blocks
      @blocks ||= []
    end
    alias scripts blocks

    # Add a block of code to be executed during initialization.
    #
    # These blocks are primarily used to define actions, scenes, and hooks in
    # the narrative's rulebook.
    #
    # Dynamic entities should be created with #seed.
    #
    def script &block
      blocks.push Block.new(:script, block)
    end

    # Add a block of code to generate content after initialization.
    #
    # Seeds run after the initial scripts have been executed. Their primary
    # use is to add entities and other data components, especially randomized
    # or procedurally generated content that can vary between instances.
    #
    # @note Seeds do not get executed when a narrative is restored from a
    #   snapshot.
    #
    # @example
    #   class MyPlot < Gamefic::Plot
    #     seed do
    #       @thing = make Gamefic::Entity, name: 'a thing'
    #     end
    #   end
    #
    def seed &block
      blocks.push Block.new(:seed, block)
    end

    def included_blocks
      included_modules.that_are(Scriptable)
                      .flat_map(&:blocks)
                      .concat(blocks)
    end
  end
end
