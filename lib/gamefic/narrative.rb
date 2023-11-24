module Gamefic
  # A base class for building and managing the resources that compose a story.
  #
  class Narrative
    module ScriptMethods
      # @return [Array<Gamefic::Entity>]
      def entities
        @entities ||= [].freeze
      end

      # @return [Array<Gamefic::Actor>]
      def players
        @players ||= [].freeze
      end
    end

    include Logging
    include ScriptMethods

    class << self
      # @return [Array<Proc>]
      def scripts
        @scripts ||= []
      end
      alias blocks scripts

      # Add a block to be executed during initialization.
      #
      # These blocks are where actions and scenes should be defined. After they
      # get executed, the playbook and scenebook will be frozen. Any entities
      # created in these blocks will be considered "static."
      #
      def script &block
        scripts.push block
      end
    end

    def initialize
      run_scripts
      playbook.freeze
      scenebook.freeze
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
      return unless @introduction

      take = Take.new(player, @introduction)
      take.start
      player.stream take.output[:messages]
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
      return player if @players&.include?(player)

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
