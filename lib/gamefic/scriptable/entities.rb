# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating entities.
    #
    # @note The public versions of the entity and player arrays are frozen.
    #   Authors need access to them but shouldn't modify them directly.
    #   Instead, they should create new entities with the #make method.
    #
    module Entities
      # @return [Array<Gamefic::Entity>]
      def entities
        @entities ||= [].freeze
      end

      # @return [Array<Gamefic::Actor, Gamefic::Active>]
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
        entities_safe_push klass.new(**opts)
      end

      def destroy entity
        entity.children.each { |child| child.parent = entity.parent }
        entity.parent = nil
        entities_safe_delete entity
      end

      # Pick an entity based on a unique name or description. Return nil if an
      # entity could not be found or there is more than one possible match.
      #
      # @param description [String]
      # @return [Gamefic::Entity, nil]
      def pick description
        Gamefic::Query::General.new(entities).query(nil, description).match
      end

      # Same as #pick, but raise an error if a unique match could not be found.
      #
      # @param description [String]
      # @return [Gamefic::Entity, nil]
      def pick! description
        ary = Gamefic::Query::General.new(entities, ambiguous: true).query(nil, description).match

        raise "no entity matching '#{description}'" if ary.empty?

        raise "multiple entities matching '#{description}': #{ary.join_and}" unless ary.one?

        ary.first
      end

      private

      # @param entity [Entity]
      def entities_safe_push entity
        @entities = @entities.dup || []
        @entities.push(entity).freeze
        entity
      end

      # @param entity [Entity]
      def entities_safe_delete entity
        idx = entities.find_index(entity)
        if idx < static_size
          logger.warn "Cannot delete static entity `#{entity}`"
        else
          @entities = (@entities.dup - [entity]).freeze
        end
      end

      # @param player [Actor, Active]
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
    end
  end
end
