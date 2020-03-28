module Gamefic
  module Serialize
    def to_serial
      {
        'class' => serialized_class
      }.merge serialize_instance_variables
    end

    def serialized_class
      Index.element_name(self.class) || self.class.to_s
    end
  end
end

class Object
  def to_serial
    return self if [true, false, nil].include?(self)
    # @todo This warning is a little too spammy. Set up a logger so it can be
    # limited to an info or debug level.
    # STDERR.puts "Unable to convert #{self} to element"
    "#<UNKNOWN>"
  end

  def serialize_instance_variables
    result = {}
    instance_variables.each do |k|
      result[k.to_s] = instance_variable_get(k).to_serial
    end
    result
  end
end

class Symbol
  def to_serial
    "#<SYM:#{self}>"
  end
end

class String
  def to_serial
    self
  end
end

class Numeric
  def to_serial
    self
  end
end

class Array
  def to_serial
    map do |e|
      s = e.to_serial
      return "#<UNKNOWN>" if s == "#<UNKNOWN>"
      s
    end
  end
end

class Hash
  def to_serial
    result = {}
    each_pair do |key, value|
      k2 = key.to_serial
      v2 = value.to_serial
      return "#<UNKNOWN>" if k2 == "#<UNKNOWN>" || v2 == "#<UNKNOWN>"
      result[k2] = v2
    end
    result
  end
end
