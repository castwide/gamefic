require 'json'

module Gamefic
  module Index
    @@elements = []
    @@stuck_length = 0

    def initialize **data
      data.each_pair do |k, v|
        public_send "#{k}=", v
      end
      @@elements.push self
    end

    def to_serial
      index = @@elements.index(self)
      raise RuntimeError, "#{self} is not an indexed element" unless index
      "#<ELE_#{index}>"
    end

    def destroy
      @@elements.delete self unless Index.stuck?(self)
    end

    def self.elements
      @@elements
    end

    def self.serials
      result = []
      @@elements.each do |e|
        d = {}
        d[:class] = e.class.to_s
        e.instance_variables.each do |k|
          v = e.instance_variable_get(k)
          d[k] = v.to_serial
        end
        result.push d
      end
      result
    end

    def self.from_element element
      if element.is_a?(Hash) && element[:class]
        klass = eval(element[:class])
        object = klass.allocate
        element.each_pair do |k, v|
          next unless k.to_s.start_with?('@')
          object.instance_variable_set(k, from_element(v))
        end
        object
      elsif element.is_a?(Numeric)
        element
      elsif element.is_a?(String)
        match = element.match(/#<ELE_([0-9]+)>/)
        return Gamefic::Index.elements[match[1].to_i] if match
        match = element.match(/#<SYM:([a-z0-9_\?\!]+)>/i)
        return match[1].to_sym if match
        element
      elsif element.is_a?(Array)
        element.map { |e| from_element(e) }
      elsif element.is_a?(Hash)
        result = {}
        element.each_pair do |k, v|
          result[from_element(k)] = from_element(v)
        end
        result
      elsif element && element != true
        STDERR.puts "Unable to unserialize #{element.class}"
        nil
      else
        # true, false, or nil
        element
      end
    end

    def self.unserialize serials
      serials.each_with_index do |s, i|
        next if elements[i]
        klass = eval(s[:class])
        klass.new
      end
      serials.each_with_index do |s, i|
        s.each_pair do |k, v|
          next unless k.to_s.start_with?('@')
          next if v == "#<UNKNOWN>"
          elements[i].instance_variable_set(k, from_element(v))
        end
      end
      elements
    end

    def self.stick
      @@stuck_length = @@elements.length
    end

    def self.clear
      @@stuck_length = 0
      @@elements.clear
    end

    def self.stuck? thing
      index = @@elements.index(thing)
      index && index <= @@stuck_length - 1
    end
  end
end
