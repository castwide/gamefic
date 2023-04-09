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
    end
  end
end
