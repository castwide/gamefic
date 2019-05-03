module Gamefic
  module Query
    class Text < Base
      def initialize *arguments
        arguments.each { |a|
          if (a.kind_of?(Symbol) or a.kind_of?(String)) and !a.to_s.end_with?('?')
            raise ArgumentError.new("Text query arguments can only be boolean method names (:method?) or regular expressions")
          end
        }
        super
      end
      def resolve(subject, token, continued: false)
        return Matches.new([], '', token) unless accept?(token)
        parts = token.split(Keywords::SPLIT_REGEXP)
        cursor = []
        matches = []
        i = 0
        parts.each { |w|
          cursor.push w
          matches = cursor if accept?(cursor.join(' '))
          i += 1
        }
        if continued
          Matches.new([matches.join(' ')], matches.join(' '), parts[i..-1].join(' '))
        else
          if matches.length == parts.length
            Matches.new([matches.join(' ')], matches.join(' '), '')
          else
            Matches.new([], '', parts.join(' '))
          end
        end
      end

      def include?(subject, token)
        accept?(token)
      end

      def accept?(entity)
        return false unless entity.kind_of?(String) and !entity.empty?
        super
      end

      def precision
        0
      end
    end
  end
end
