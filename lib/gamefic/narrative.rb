module Gamefic
  # A base class for building and managing the resources that compose a story.
  #
  class Narrative
    include Logging

    class << self
      def blocks
        @blocks ||= []
      end

      def script &block
        blocks.push block
      end
    end

    attr_reader :digest

    # @param scriptables [Array<Symbol>] Scriptable method names
    def initialize(scriptables = [])
      @scriptables = scriptables
      run_scripts
      playbook.freeze
      scenebook.freeze
      theater.freeze
    end

    def director
      @director ||= Director.new(self, @scriptables)
    end

    def theater
      @theater ||= Theater.new
    end

    # @return [Array<Gamefic::Entity>]
    def entities
      @entities ||= [].freeze
    end

    # @return [Array<Gamefic::Actor>]
    def players
      @players ||= [].freeze
    end

    # @return [Playbook]
    def playbook
      @playbook ||= Playbook.new
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
      players_safe_push player
      return unless @introduction

      take = Take.new(player, @introduction)
      take.start
    end

    # A narrative is considered to be concluding when it only players are in
    # a conclusion scene. Engines can use this method to determine whether the
    # game is ready to end.
    #
    def concluding?
      players.empty? || players.all? { |plyr| plyr.concluding? }
    end

    # Remove a player from the game.
    #
    def exeunt player
      uncast player
      players_safe_delete player
    end

    # Add this narrative's playbook and scenebook to an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.playbooks.add playbook
      active.scenebooks.add scenebook
      active
    end

    # Remove this narrative's playbook and scenebook from an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.playbooks.delete playbook
      active.scenebooks.delete scenebook
      active
    end

    def pick description
      Gamefic::Query::General.new(entities).query(nil, description).match
    end

    def ready
      scenebook.run_ready_blocks
    end

    def update
      scenebook.run_update_blocks
    end

    def run_scripts
      self.class.blocks.each { |blk| stage(&blk) }
      @static_size = entities.length
      @digest = Gamefic::Snapshot.digest(self)
    end

    def entities_safe_push entity
      @entities = @entities.dup || []
      @entities.push(entity).freeze
      entity
    end

    def entities_safe_delete entity
      idx = entities.find_index(entity)
      if idx < static_size
        logger.warn "Cannot delete static entity `#{entity}`"
      else
        @entities = (@entities.dup - [entity]).freeze
      end
    end

    def players_safe_push player
      @players = @players.dup || []
      @players.push(player).freeze
      player
    end

    def players_safe_delete player
      return unless @players
      @players = (@players.dup - [player]).freeze
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
