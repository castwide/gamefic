module Gamefic
  module Serialize
    def to_serial(index = [])
      # if static.include?(self)
      #   static.id_for(self)
      # else
      #  {
      #    'class' => serialized_class(static)
      #  }.merge(serialize_instance_variables(static))
      # end
      if index.include?(self)
        {
          'class' => "#<ELE_#{index.index(self)}>",
          'ivars' => serialize_instance_variables(index)
        }

      else
        {
          'class' => self.class.to_s,
          'ivars' => serialize_instance_variables(index)
        }
      end
    end

    # @todo Deprecate?
    def serialized_class(static)
      return self.class.to_s # @todo Maybe don't sweat dynamic classes
      static.id_for(self.class) || self.class.to_s
    end

    def self.instances
      GC.start
      result = []
      ObjectSpace.each_object(Gamefic::Serialize) { |obj| result.push obj }
      result
    end
  end
end

class Object
  class << self
    def exclude_from_serial ary
      @excluded_from_serial = ary
    end

    def excluded_from_serial
      @excluded_from_serial ||= []
    end
  end

  def to_serial(_index)
    return self if [true, false, nil].include?(self)
    # @todo This warning is a little too spammy. Set up a logger so it can be
    # limited to an info or debug level.
    # STDERR.puts "Unable to convert #{self} to element"
    "#<UNKNOWN>"
  end

  def from_serial(index = [])
    if self.is_a?(Hash) && (self['class'])
      if self['class']
        elematch = self['class'].match(/^#<ELE_([\d]+)>$/)
        if elematch
          klass = index[elematch[1].to_i]
        else
          klass = eval(self['class'])
        end
        object = klass.allocate
      end
      self['ivars'].each_pair do |k, v|
        object.instance_variable_set(k, v.from_serial(index))
      end
      object
    elsif self.is_a?(Numeric)
      self
    elsif self.is_a?(String)
      match = self.match(/#<ELE_([0-9]+)>/)
      return index.index(match[1].to_i) if match
      match = self.match(/#<SYM:([a-z0-9_\?\!]+)>/i)
      return match[1].to_sym if match
      self
    elsif self.is_a?(Hash)
      result = {}
      unknown = false
      self.each_pair do |k, v|
        k2 = k.from_serial(index)
        v2 = v.from_serial(index)
        if k2 == "#<UNKNOWN>" || v2 == "#<UNKNOWN>"
          unknown = true
          break
        end
        result[k2] = v2
      end
      result = "#<UNKNOWN>" if unknown
      result
    elsif self && self != true
      STDERR.puts "Unable to unserialize #{self.class}"
      nil
    else
      # true, false, or nil
      self
    end
  end

  def serialize_instance_variables(index)
    result = {}
    instance_variables.each do |k|
      next if self.class.excluded_from_serial.include?(k)
      # result[k.to_s] = instance_variable_get(k).to_serial(static)
      result[k.to_s] = instance_variable_get(k).to_serial(index)
    end
    result
  end
end

class Symbol
  def to_serial(_index = [])
    "#<SYM:#{self}>"
  end
end

class String
  def to_serial(_index = [])
    self
  end
end

class Numeric
  def to_serial(_index = [])
    self
  end
end

class Array
  def to_serial(index = [])
    map do |e|
      s = e.to_serial(index)
      return "#<UNKNOWN>" if s == "#<UNKNOWN>"
      s
    end
  end

  def from_serial(index = [])
    result = map { |e| e.from_serial(index) }
    result = "#<UNKNOWN>" if result.any? { |e| e == "#<UNKNOWN>" }
    result
  end
end

class Hash
  def to_serial(index = [])
    result = {}
    each_pair do |key, value|
      k2 = key.to_serial(index)
      v2 = value.to_serial(index)
      return "#<UNKNOWN>" if k2 == "#<UNKNOWN>" || v2 == "#<UNKNOWN>"
      result[k2] = v2
    end
    result
  end
end
