module Gamefic
  module Serialize
    def to_serial(index = [])
      if index.include?(self)
        {
          'instance' => "#<ELE_#{index.index(self)}>",
          'ivars' => serialize_instance_variables(index)
        }
      else
        if self.class == Class && self.name
          {
            'class' => 'Class',
            'name' => name
          }
        else
          index.push self if self.is_a?(Gamefic::Serialize)
          {
            'class' => serialized_class(index),
            'ivars' => serialize_instance_variables(index)
          }
        end
      end
    end

    def serialized_class index
      if index.include?(self.class)
        "#<ELE_#{index.index(self.class)}>"
      else
        self.class.to_s
      end
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
    if self.is_a?(Hash) && (self['class'] || self['instance'])
      if self['instance']
        elematch = self['instance'].match(/^#<ELE_([\d]+)>$/)
        object = index[elematch[1].to_i]
        raise "Unable to load indexed element ##{elematch[1]} #{self}" if object.nil?
      elsif self['class']
        if self['class'] == 'Class'
          return eval(self['name'])
        else
          elematch = self['class'].match(/^#<ELE_([\d]+)>$/)
          if elematch
            klass = index[elematch[1].to_i]
          else
            klass = eval(self['class'])
          end
          raise "Unable to find class #{self['class']} #{self}" if klass.nil?
          object = klass.allocate
          index.push object if object.is_a?(Gamefic::Serialize)
        end
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
      # return nil if self == '#<UNKNOWN>'
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
      val = instance_variable_get(k)
      if index.include?(val)
        result[k.to_s] = {
          'instance' => "#<ELE_#{index.index(val)}>",
          'ivars' => {}
        }
      else
        result[k.to_s] = val.to_serial(index)
        index.push val if val.is_a?(Gamefic::Serialize) && val.class != Class
      end
    end
    result
  end
end

class Class
  def to_serial(index = [])
    if name.nil?
      super
    else
      {
        'class' => 'Class',
        'name' => name
      }
    end
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
