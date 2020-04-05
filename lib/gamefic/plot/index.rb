module Gamefic
  class Plot
    # A fixed index of plot elements. Plots and subplots use an index to track
    # objects created in scripts.
    #
    class Index
      # @param elements [Array]
      def initialize elements
        @elements = elements.uniq.freeze
      end

      # @return [Boolean]
      def include? element
        @elements.include?(element)
      end

      def all
        @elements
      end

      def concat elements
        @elements = (@elements + elements).uniq.freeze
      end

      def remove elements
        @elements = (@elements - elements).uniq.freeze
      end

      # @return [Object]
      def element index
        @elements[index]
      end

      def id_for(element)
        include?(element) ? "#<ELE_#{@elements.index(element)}>" : nil
      end

      # def self.from_serial serial, static
      #   if serial.is_a?(Hash) && (serial['class'] || serial['element'])
      #     if serial['class']
      #       elematch = serial['class'].match(/^#<ELE_([\d]+)>$/)
      #       if elematch
      #         klass = static.element(elematch[1].to_i)
      #       else
      #         klass = eval(serial['class'])
      #       end
      #       object = klass.allocate
      #     elsif serial['element']
      #       object = static.element(serial['element'])
      #     end
      #     serial.each_pair do |k, v|
      #       next unless k.to_s.start_with?('@')
      #       object.instance_variable_set(k, from_serial(v, static))
      #     end
      #     object
      #   elsif serial.is_a?(Numeric)
      #     serial
      #   elsif serial.is_a?(String)
      #     match = serial.match(/#<ELE_([0-9]+)>/)
      #     return static.element(match[1].to_i) if match
      #     match = serial.match(/#<SYM:([a-z0-9_\?\!]+)>/i)
      #     return match[1].to_sym if match
      #     serial
      #   elsif serial.is_a?(Array)
      #     result = serial.map { |e| from_serial(e, static) }
      #     result = "#<UNKNOWN>" if result.any? { |e| e == "#<UNKNOWN>" }
      #     result
      #   elsif serial.is_a?(Hash)
      #     result = {}
      #     unknown = false
      #     serial.each_pair do |k, v|
      #       k2 = from_serial(k, static)
      #       v2 = from_serial(v, static)
      #       if k2 == "#<UNKNOWN>" || v2 == "#<UNKNOWN>"
      #         unknown = true
      #         break
      #       end
      #       result[k2] = v2
      #     end
      #     result = "#<UNKNOWN>" if unknown
      #     result
      #   elsif serial && serial != true
      #     STDERR.puts "Unable to unserialize #{serial.class}"
      #     nil
      #   else
      #     # true, false, or nil
      #     serial
      #   end
      # end
    end
  end
end
