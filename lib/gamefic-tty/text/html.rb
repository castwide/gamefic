require 'rexml/document'
require 'gamefic-tty/text/html/entities'

module Gamefic
  module Tty::Text
    module Html
      autoload :Conversions, 'gamefic-tty/text/html/conversions'

      # Convert ampersands to &amp;
      #
      # @param text [String]
      # @return [String]
      def self.fix_ampersands(text)
        codes = []
        ENTITIES.keys.each { |e|
          codes.push e[1..-1]
        }
        piped = codes.join('|')
        re = Regexp.new("&(?!(#{piped}))")
        text.gsub(re, '&amp;\1')
      end
      
      # Encode a String with HTML entities
      #
      # @param text [String]
      # @return [String]
      def self.encode(text)
        encoded = text
        ENTITIES.each { |k, v|
          encoded = encoded.gsub(v, k)
        }
        encoded
      end
      
      # Decode a String's HTML entities
      #
      # @param text [String]
      # @return [String]
      def self.decode(text)
        ENTITIES.each { |k, v|
          text = text.gsub(k, v)
        }
        text
      end
      
      # Parse a String into an XML document
      #
      # @param code [String]
      # @return [REXML::Document]
      def self.parse(code)
        code = fix_ampersands(code).strip
        last = nil
        begin
          doc = REXML::Document.new code
        rescue REXML::ParseException => e
          # Convert invalid < characters to &lt;
          if e.source.buffer != last and e.source.buffer[0,1] == '<'
            code = code[0,(code.length - e.source.buffer.length)] + '&lt;' + e.source.buffer[1..-1]
            last = e.source.buffer
            retry
          end
          raise e
        end
      end
    end
  end

end
