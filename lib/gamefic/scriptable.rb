# frozen_string_literal: true

require 'set'

module Gamefic
  # A class module that enables scripting.
  #
  # Narratives extend Scriptable to enable definition of scripts and seeds.
  # Modules can also be extended with Scriptable to make them importable into
  # other Scriptables.
  #
  # @example Import a scriptable module into Plot
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
  #   Gamefic::Plot.import MyScript
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
    # the narrative's rulebook. After they get executed, the rulebook will be
    # frozen.
    #
    # Dynamic entities should be created with #seed.
    #
    def script &block
      blocks.push Block::Script.new(block)
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
    def seed &block
      blocks.push Block::Seed.new(block)
    end

    # Add a Scriptable module's scripts to the caller.
    #
    # @param mod [Scriptable]
    def import mod
      return false if imported.include?(mod)

      scripts.concat mod.scripts
      imported.add mod
    end

    def inherited subclass
      super
      subclass.import self
    end

    private

    def imported
      @imported ||= Set.new
    end
  end
end
