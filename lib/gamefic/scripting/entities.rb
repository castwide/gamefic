module Gamefic
  module Scripting
    module Entities
      # @return [Array<Gamefic::Entity>]
      attr_reader :entities

      # @return [Array<Gamefic::Actor>]
      attr_reader :players

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
    end
  end
end
