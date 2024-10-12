# frozen_string_literal: true

module Gamefic
  class Narrative
    # Methods related to managing entities.
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

      def find *args
        args.inject(entities) do |entities, arg|
          case arg
          when String
            result = Scanner.scan(entities, arg)
            result.remainder.empty? ? result.match : []
          else
            entities.that_are(arg)
          end
        end
      end

      # Pick a unique entity based on the given arguments. String arguments are
      # used to scan the entities for matching names and synonyms. Return nil
      # if an entity could not be found or there is more than one possible
      # match.
      #
      # @param description [Array]
      # @return [Gamefic::Entity, nil]
      def pick *args
        matches = find(*args)
        return nil unless matches.one?

        matches.first
      end

      # Same as #pick, but raise an error if a unique match could not be found.
      #
      #
      # @raise [RuntimeError] if a unique match was not found.
      #
      # @param args [Array]
      # @return [Gamefic::Entity]
      def pick! *args
        matches = find(*args)
        raise "no entity matching '#{args.inspect}'" if matches.empty?
        raise "multiple entities matching '#{args.inspect}': #{matches.join_and}" unless matches.one?

        matches.first
      end
    end
  end
end
