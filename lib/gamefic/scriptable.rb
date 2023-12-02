# frozen_string_literal: true

module Gamefic
  # A class module that enables scripting.
  #
  # Narratives extend Scriptable to enable definition of scripts and seeds.
  # Scriptable also provides the ability to import scripts from modules that
  # extend Scriptable.
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
    autoload :Actions,  'gamefic/scriptable/actions'
    autoload :Entities, 'gamefic/scriptable/entities'
    autoload :Queries,  'gamefic/scriptable/queries'
    autoload :Plots,    'gamefic/scriptable/plots'
    autoload :Scenes,   'gamefic/scriptable/scenes'
    autoload :Subplots, 'gamefic/scriptable/subplots'

    # @return [Array<Block>]
    def scripts
      @scripts ||= []
    end
    alias blocks scripts

    # Add a block of code to be executed during initialization.
    #
    # These blocks are used to define actions, scenes, and static entities.
    # After they get executed, the playbook and scenebook will be frozen.
    #
    # Dynamic entities should be created with #seed.
    #
    # @yieldself [ScriptMethods]
    def script &block
      scripts.push Block.new(:script, block)
    end

    # Add a block of code to generate content after initialization.
    #
    # Seeds run after the initial scripts have been executed. Their primary
    # use is to add entities and other components, especially randomized or
    # procedurally generated content that can vary between instances.
    #
    # @note Seeds do not get executed when a narrative is restored from a
    #   snapshot.
    #
    # @yieldself [Delegatable::Entities]
    def seed &block
      scripts.push Block.new(:seed, block)
    end

    def delegators(with_inherited: true)
      (with_inherited && superclass <= Narrative ? superclass.delegators : []) + local_delegators
    end

    def delegated_methods(with_inherited: true)
      delegators(with_inherited: with_inherited).flat_map(&:public_instance_methods).uniq
    end

    # Assign a delegator module for scripts.
    #
    # @param [Module]
    def delegate delegator
      include delegator
      local_delegators.push delegator
    end

    # @param mod [Importable]
    def import mod
      return false if imported.include?(mod)

      scripts.concat mod.scripts
      imported.add mod
    end

    private

    def imported
      @imported ||= Set.new
    end

    def local_delegators
      @local_delegators ||= []
    end
  end
end
