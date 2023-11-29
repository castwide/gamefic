# frozen_string_literal: true

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    module ScriptMethods
      include Scriptable::Actions
      include Scriptable::Entities
      include Scriptable::Queries
      include Scriptable::Scenes
    end

    class << self
      def delegators(with_inherited: true)
        (with_inherited && superclass <= Narrative ? superclass.delegators : []) + local_delegators
      end

      def delegated_methods(with_inherited: true)
        delegators(with_inherited: with_inherited).flat_map(&:public_instance_methods).uniq
      end

      # @return [Array<Proc>]
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
      # procedurally generated content that can vary from instance to instance.
      #
      # @note Seeds do not get executed when a narrative is restored from a
      #   snapshot.
      #
      # @yieldself [Scriptable::Entities]
      def seed &block
        scripts.push Block.new(:seed, block)
      end

      # Assign a delegator module for scripts.
      #
      # @param [Module]
      def delegate delegator
        include delegator
        local_delegators.push delegator
      end

      private

      def local_delegators
        @local_delegators ||= []
      end
    end

    include Logging
    # @!parse include ScriptMethods
    delegate ScriptMethods

    # @return [Integer]
    attr_reader :digest

    # @return [Hash]
    attr_reader :config

    def initialize
      run_scripts
      run_seeds
      theater.freeze
    end

    def theater
      @theater ||= Theater.new
    end

    # @return [Playbook]
    def playbook
      @playbook ||= Playbook.new(method(:stage))
    end

    # @return [Scenebook]
    def scenebook
      @scenebook ||= Scenebook.new(method(:stage))
    end

    # @param block [Proc]
    def stage *args, &block
      theater.evaluate self, *args, block
    end

    # Introduce an actor to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      cast player
      scenebook.introductions.each do |scene|
        take = Take.new(player, scene)
        take.start
        player.stream take.output[:messages]
      end
    end

    # A narrative is considered to be concluding when all of its players are in
    # a conclusion scene. Engines can use this method to determine whether the
    # game is ready to end.
    #
    def concluding?
      players.empty? || players.all?(&:concluding?)
    end

    # Remove a player from the game.
    #
    def exeunt player
      scenebook.run_player_conclude_blocks player
      uncast player
    end

    # Add this narrative's playbook and scenebook to an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.playbooks.add playbook
      active.scenebooks.add scenebook
      players_safe_push active
      active
    end

    # Remove this narrative's playbook and scenebook from an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.playbooks.delete playbook
      active.scenebooks.delete scenebook
      players_safe_delete active
      active
    end

    def ready
      scenebook.run_ready_blocks
    end

    def update
      scenebook.run_update_blocks
    end

    # @return [void]
    def run_scripts
      self.class.blocks.select(&:script?).each { |blk| stage(&blk.proc) }
      @static_size = entities.length
      @digest = Gamefic::Snapshot.digest(self)
      playbook.freeze
      scenebook.freeze
    end

    # @return [void]
    def run_seeds
      self.class.blocks.select(&:seed?).each { |blk| stage(&blk.proc) }
    # These errors are modified to provide a more informative message when
    # frozen rulebook errors occur from seed scripts.
    rescue FrozenScenebookError => e
      raise e.class, "Scenebooks cannot be modified from seeds. Try `script` instead", e.backtrace
    rescue FrozenPlaybookError => e
      raise e.class, "Playbooks cannot be modified from seeds. Try `script` instead", e.backtrace
    end

    # The size of the entities array after initialization. Narratives use this
    # to determine how it should treat destroyed entities. If the entity is
    # inside the section of the array considered static, its position needs
    # to be retained to ensure the validity of entity proxies.
    #
    # @return [Integer]
    def static_size
      @static_size ||= 0
    end
  end
end
