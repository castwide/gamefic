module Gamefic

  module Plot::EntityMount
    # Make a new Entity with the provided properties.
    #
    # @example Create an Entity
    #   chair = make Entity, :name => 'red chair'
    #   chair.name #=> 'red chair'
    #
    # @param cls [Class] The Class of the Entity to be created.
    # @param args [Hash] The entity's properties.
    # @return The Entity instance.
    def make(cls, args = {}, &block)
      ent = cls.new(self, args, &block)
      if ent.kind_of?(Entity) == false
        raise "Invalid entity class"
      end
      ent
    end
    # Pick an entity based on its description.
    # The description provided must match exactly one entity; otherwise
    # an error is raised.
    #
    # @example Select the Entity that matches the description
    #   red_chair = make Entity, :name => 'red chair'
    #   blue_chair make Entity, :name => 'blue chair'
    #   pick "red chair" #=> red_chair
    #   pick "blue chair" #=> blue_chair
    #   pick "chair" #=> IndexError: description is ambiguous
    #
    # @param @description [String] The description of the entity
    # @return [Entity] The entity that matches the description
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
  end

end
