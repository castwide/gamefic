module Gamefic

  module Plot::EntityMount
    def make(cls, args = {}, &block)
      ent = cls.new(self, args, &block)
      if ent.kind_of?(Entity) == false
        raise "Invalid entity class"
      end
      ent
    end
    def pick(description)
      result = Query.match(description, entities)
      if result.objects.length == 0
        raise "Unable to find entity from '#{description}'"
      elsif result.objects.length > 1
        raise "Ambiguous entities found from '#{description}'"
      end
      result.objects[0]
    end
    def _(description)
      pick description
    end
  end

end
