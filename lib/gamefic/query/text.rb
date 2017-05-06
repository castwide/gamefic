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
      def resolve(subject, token)
        result = []
        result.push(token) if accept?(token)
        result
      end

      def include?(subject, token)
        accept?(token)
      end

      def accept?(entity)
        return false unless entity.kind_of?(String)
        super
      end

      def precision
        arguments.length
      end
    end
  end
end
