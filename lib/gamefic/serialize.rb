module Gamefic
  module Serialize
    def to_serial(static)
      if static.include?(self)
        static.id_for(self)
      else
        {
          'class' => serialized_class(static)
        }.merge(serialize_instance_variables(static))
      end
    end

    def serialized_class(static)
      static.id_for(self.class) || self.class.to_s
    end
  end
end

class Object
  def to_serial(_static)
    return self if [true, false, nil].include?(self)
    # @todo This warning is a little too spammy. Set up a logger so it can be
    # limited to an info or debug level.
    # STDERR.puts "Unable to convert #{self} to element"
    "#<UNKNOWN>"
  end

  def serialize_instance_variables(static)
    result = {}
    instance_variables.each do |k|
      result[k.to_s] = instance_variable_get(k).to_serial(static)
    end
    result
  end
end

class Symbol
  def to_serial(_static)
    "#<SYM:#{self}>"
  end
end

class String
  def to_serial(_static)
    self
  end
end

class Numeric
  def to_serial(_static)
    self
  end
end

class Array
  def to_serial(static)
    map do |e|
      s = e.to_serial(static)
      return "#<UNKNOWN>" if s == "#<UNKNOWN>"
      s
    end
  end
end

class Hash
  def to_serial(static)
    result = {}
    each_pair do |key, value|
      k2 = key.to_serial(static)
      v2 = value.to_serial(static)
      return "#<UNKNOWN>" if k2 == "#<UNKNOWN>" || v2 == "#<UNKNOWN>"
      result[k2] = v2
    end
    result
  end
end
