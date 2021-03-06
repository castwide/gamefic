module Gamefic
  module Query
    class Matches
      # The resolved tokens
      # @return [Array<Object>]
      attr_reader :objects

      # The matching string
      # @return [String]
      attr_reader :matching

      # The remaining (unmatched) string
      # @return [String]
      attr_reader :remaining

      def initialize objects, matching, remaining
        @objects = objects
        @matching = matching
        @remaining = remaining
      end

      def self.execute objects, description, continued: false
        if continued
          match_with_remainder objects, description
        else
          match_without_remainder objects, description
        end
      end

      class << self
        private

        def match_without_remainder objects, description
          matches = objects.select{ |e| e.specified?(description) }
          if matches.empty?
            matching = ''
            remaining = description
          else
            matching = description
            remaining = ''
          end
          Matches.new(matches, matching, remaining)
        end

        def match_with_remainder objects, description
          matching_objects = objects
          matching_text = []
          words = description.split(Keywords::SPLIT_REGEXP)
          i = 0
          words.each { |w|
            cursor = inner_match matching_objects, words, matching_text, i, w
            break if cursor.empty? or (cursor & matching_objects).empty?
            matching_objects = (cursor & matching_objects)
            i += 1
          }
          objects = matching_objects
          matching = matching_text.uniq.join(' ')
          remaining = words[i..-1].join(' ')
          Matches.new(objects, matching, remaining)
        end

        def inner_match matching_objects, words, matching_text, i, w
          cursor = []
          matching_objects.each { |o|
            if o.specified?(words[0..i].join(' '), fuzzy: true)
              cursor.push o
              matching_text.push w
            end
          }
          cursor
        end
      end
    end
  end
end
