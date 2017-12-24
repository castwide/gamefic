module Gamefic
  module World
    module Entities
      # Make a new Entity with the provided properties.
      #
      # @example Create an Entity
      #   chair = make Entity, name: 'red chair'
      #   chair.name #=> 'red chair'
      #
      # @param cls [Class] The Class of the Entity to be created.
      # @param args [Hash] The entity's properties.
      # @return [Gamefic::Entity]
      def make cls, args = {}, &block
        ent = cls.new args, &block
        if ent.kind_of?(Entity) == false
          raise "Invalid entity class"
        end
        p_entities.push ent
        p_dynamic.push ent if running?
        ent
      end

      # Cast an active entity.
      # This method is similar to make, but it also provides the plot's
      # playbook to the entity so it can perform actions. The entity should
      # either be a kind of Gamefic::Actor or include the Gamefic::Active
      # module.
      #
      # @return [Gamefic::Actor, Gamefic::Active]
      def cast cls, args = {}, &block
        ent = make cls, args, &block
        ent.playbooks.push playbook
        ent
      end

      # Safely remove an entity from a plot.
      # If the entity is dynamic (e.g., created after a plot is already
      # running), it is safe to delete it completely. Otherwise the entity
      # will still be referenced in the entities array, but its parent will be
      # set to nil.
      #
      # @param [Gamefic::Entity] The entity to remove
      def destroy entity
        if p_dynamic.include?(entity)
          p_entities.delete entity
          p_dynamic.delete entity
          p_players.delete entity
        end
        entity.parent = nil
      end

      # Pick an entity based on its description.
      # The description provided must match exactly one entity; otherwise
      # an error is raised.
      #
      # @example Select the Entity that matches the description
      #   red_chair = make Entity, :name => 'red chair'
      #   blue_chair = make Entity, :name => 'blue chair'
      #   pick "red chair" #=> red_chair
      #   pick "blue chair" #=> blue_chair
      #   pick "chair" #=> IndexError: description is ambiguous
      #
      # @param  description [String] The description of the entity
      # @return [Gamefic::Entity] The entity that matches the description
      def pick(description)
        query = Gamefic::Query::Base.new
        result = query.match(description, entities)
        if result.objects.length == 0
          raise IndexError.new("Unable to find entity from '#{description}'")
        elsif result.objects.length > 1
          raise IndexError.new("Ambiguous entities found from '#{description}'")
        end
        result.objects[0]
      end

      # Get an array of entities associated with this plot.
      #
      # @return [Array<Gamefic::Entity>]
      def entities
        p_entities.clone
      end

      # Get an array of players associated with this plot.
      #
      # @return [Array<Gamefic::Actor>]
      def players
        p_players.clone
      end

      private

      def p_entities
        @p_entities ||= []
      end

      def p_players
        @p_players ||= []
      end

      def p_dynamic
        @p_dynamic ||= []
      end
    end
  end
end
