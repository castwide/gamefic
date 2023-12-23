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
    def scripts
      @scripts ||= []
    end
    alias blocks scripts

    # Add a block of code to be executed during initialization.
    #
    # These blocks are primarily used to define actions, scenes, and hooks in
    # the narrative's rulebook. After they get executed, the rulebook will be
    # frozen.
    #
    # Dynamic entities should be created with #seed.
    #
    def script &block
      scripts.push Block.new(:script, block)
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
      scripts.push Block.new(:seed, block)
    end

    # @return [Array<Module>]
    def delegators(with_inherited: true)
      (with_inherited && superclass <= Narrative ? superclass.delegators : []) + local_delegators
    end

    # @return [Array<Symbol>]
    def delegated_methods(with_inherited: true)
      delegators(with_inherited: with_inherited).flat_map(&:public_instance_methods)
                                                .concat(inner_delegated_methods(with_inherited: with_inherited))
                                                .uniq
    end

    # Assign a delegator module for scripts.
    #
    # Delegators provide scripts with access to methods that get forwarded to
    # the narrative instance.
    #
    # @example
    #   module MyDelegator
    #     def entity_count
    #       entities.count
    #     end
    #   end
    #
    #   Gamefic::Plot.delegate MyDelegator
    #
    #   Gamefic::Plot.script do
    #     on_update do
    #       puts "There are #{entity_count} entities."
    #     end
    #   end
    #
    # @param [Module]
    def delegate delegator
      include delegator
      local_delegators.push delegator
    end

    def delegate_method symbol
      local_delegated_methods.push symbol
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

    # @return [Array<Module>]
    def local_delegators
      @local_delegators ||= []
    end

    def inner_delegated_methods(with_inherited: true)
      (with_inherited && superclass <= Narrative ? superclass.local_delegated_methods : []) + local_delegated_methods
    end

    protected

    # @return [Array<Symbol>]
    def local_delegated_methods
      @local_delegated_methods ||= []
    end
  end
end
