# frozen_string_literal: true

module Gamefic
  module Delegatable
    # Scriptable methods related to managing entities.
    #
    # @note The public versions of the entity and player arrays are frozen.
    #   Authors need access to them but shouldn't modify them directly. Use
    #   #make and #destroy instead.
    #
    module Entities
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
        Gamefic::Query::General.new(entities).query(nil, description).match
      end

      # Same as #pick, but raise an error if a unique match could not be found.
      #
      # @param description [String]
      # @return [Gamefic::Entity, nil]
      def pick! description
        ary = Gamefic::Query::General.new(entities, ambiguous: true).query(nil, description).match

        raise "no entity matching '#{description}'" if ary.nil?

        raise "multiple entities matching '#{description}': #{ary.join_and}" unless ary.one?

        ary.first
      end

      def unproxy object
        case object
        when Proxy
          object.fetch self
        when Array
          object.map { |obj| unproxy obj }
        when Hash
          object.transform_values { |val| unproxy val }
        else
          object
        end
      end
    end
  end
end
