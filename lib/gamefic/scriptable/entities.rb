# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating entities.
    #
    # @note The public versions of entities and players arrays are frozen.
    #   Authors need access to them but shouldn't modify them directly.
    #   Instead, they should create new entities with the #make method.
    #
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
        index = entities.length
        entity = klass.allocate
        entities_safe_push entity
        setup.entities.prepare do
          entity.send :initialize, **opts
          entity
        end
        Proxy.new(self, index)
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
    end
  end
end
