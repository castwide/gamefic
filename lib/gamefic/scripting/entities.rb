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
      def make klass, **args
        entity = klass.new(**args)

        if entity.eid && entities.any? { |e| e.eid == entity.eid }
          raise ArgumentError, "Error creating entity: EID '#{entity.eid}' already exists"
        end

        entities_safe_push entity
        entity
      end

      # Get an entity by its EID.
      #
      # @raise [NameError] if the EID does not exist
      #
      # @param key [Symbol] An entity ID
      # @return [Gamefic::Entity] The corresponding entity
      def eid key
        found = entities.find { |e| e.eid == key }
        raise NameError, "EID `#{key}` not found" unless found

        found
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
