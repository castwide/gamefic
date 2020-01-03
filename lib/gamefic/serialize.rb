module Gamefic
  module Serialize
    def to_serial
      d = {}
      d[:class] = self.class.to_s
      instance_variables.each do |k|
        v = instance_variable_get(k)
        d[k] = v.to_serial
      end
      d
    end
  end
end

class Object
  def to_serial
    return self if [true, false, nil].include?(self)
    STDERR.puts "Unable to convert #{self} to element"
    "#<UNKNOWN>"
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
    map(&:to_serial)
  end
end

class Hash
  def to_serial
    result = {}
    each_pair do |key, value|
      result[key.to_serial] = value.to_serial
    end
    result
  end
end
