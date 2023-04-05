module Gamefic
  module Scripting
    module Entities
      # @return [Array<Gamefic::Entity>]
      def entities
        @entities ||= [].freeze
      end

      # @return [Array<Gamefic::Actor>]
      def players
        @players ||= [].freeze
      end

      # Create an entity.
      #
      # @raise [ArgumentError] if the entity has a non-unique EID.
      #
      # @param [Class<Gamefic::Entity>]
      # @param args [Hash]
      # @return [Gamefic::Entity]
      def make klass, **opts
        entity = klass.allocate
        setup.entities.prepare do
          entity.send :initialize, **opts
          entities_safe_push entity
          entity
        end
        entity
      end

      private

      def entities_safe_push entity
        @entities = @entities.dup || []
        @entities.push(entity).freeze
      end

      def players_safe_push player
        @players = @players.dup || []
        @players.push(player).freeze
      end

      def entities_safe_delete entity
        return unless @entities
        @entities = (@entities.dup - [entity]).freeze
      end

      def players_safe_delete player
        return unless @players
        @players = (@players.dup - [player]).freeze
      end

      # @todo Find a good place for this or whatever
      def casting
        @casting ||= Casting.new
      end
    end
  end
end
