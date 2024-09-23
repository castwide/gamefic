# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to managing entities.
    #
    # @note The public versions of the entity and player arrays are frozen.
    #   Authors need access to them but shouldn't modify them directly. Use
    #   #make and #destroy instead.
    #
    module Entities
      include Proxies

      def entity_vault
        @entity_vault ||= Vault.new
      end

      def player_vault
        @player_vault ||= Vault.new
      end

      # @return [Array<Gamefic::Entity>]
      def entities
        entity_vault.array
      end

      # @return [Array<Gamefic::Actor, Gamefic::Active>]
      def players
        player_vault.array
      end

      # Create an entity.
      #
      # @example
      #   class MyPlot < Gamefic::Plot
      #     seed { make Gamefic::Entity, name: 'thing' }
      #   end
      #
      # @param [Class<Gamefic::Entity>]
      # @param args [Hash]
      # @return [Gamefic::Entity]
      def make klass, **opts
        entity_vault.add klass.new(**unproxy(opts))
      end

      def destroy entity
        entity.children.each { |child| destroy child }
        entity.parent = nil
        entity_vault.delete entity
      end

      # Pick an entity based on a unique name or description. Return nil if an
      # entity could not be found or there is more than one possible match.
      #
      # @param description [String]
      # @return [Gamefic::Entity, nil]
      def pick description
        result = Scanner.scan(entities, description)
        return nil unless result.matched.one?

        result.matched.first
      end

      # Same as #pick, but raise an error if a unique match could not be found.
      #
      #
      # @raise [RuntimeError] if a unique match was not found.
      #
      # @param description [String]
      # @return [Gamefic::Entity, nil]
      def pick! description
        result = Scanner.scan(entities, description)

        raise "no entity matching '#{description}'" if result.matched.empty?

        raise "multiple entities matching '#{description}': #{result.matched.join_and}" unless result.matched.one?

        result.matched.first
      end
    end
  end
end
