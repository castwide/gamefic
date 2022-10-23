module Gamefic
  module Query
    class Base
      NEST_REGEXP = / in | on | of | from | inside | from inside /

      attr_reader :arguments

      def initialize *args
        @arguments = args
      end

      # Determine whether the query allows ambiguous entity references.
      # If false, actions that use this query will only be valid if the token
      # passed into it resolves to a single entity. If true, actions will
      # accept an array of matching entities instead.
      # Queries are not ambiguous by default (ambiguous? == false).
      #
      # @return [Boolean]
      def ambiguous?
        false
      end

      # Subclasses should override this method with the logic required to collect
      # all entities that exist in the query's context.
      #
      # @return [Array<Object>]
      def context_from(subject)
        []
      end

      # Get a collection of objects that exist in the subject's context and
      # match the provided token. The result is provided as a Matches object.
      #
      # @param subject [Entity]
      # @param token [String]
      # @param continued [Boolean]
      # @return [Gamefic::Query::Matches]
      def resolve(subject, token, continued: false)
        available = context_from(subject)
        return Matches.new([], '', token) if available.empty?
        if continued
          return Matches.execute(available, token, continued: continued)
        elsif nested?(token)
          drill = denest(available, token).select { |e| accept?(e) }
          return Matches.new(drill, token, '') unless drill.length != 1
          return Matches.new([], '', token)
        end
        result = available.select { |e| e.specified?(token) }
        result = available.select { |e| e.specified?(token, fuzzy: true) } if result.empty?
        result.keep_if { |e| accept? e }
        Matches.new(result, (result.empty? ? '' : token), (result.empty? ? token : ''))
      end

      def include?(subject, object)
        return false unless accept?(object)
        result = context_from(subject)
        result.include?(object)
      end

      # A ranking of how precise the query's arguments are.
      #
      # Query precision is a factor in calculating Action#rank.
      #
      # @return [Integer]
      def precision
        if @precision.nil?
          @precision = 1
          arguments.each { |a|
            if a.is_a?(Class)
              @precision += 100
            elsif a.is_a?(Gamefic::Entity)
              @precision += 1000
            end
          }
          @precision
        end
        @precision
      end
      alias rank precision

      def signature
        "#{self.class.to_s.split('::').last.downcase}(#{simplify_arguments.join(', ')})"
      end

      # Determine whether the specified entity passes the query's arguments.
      #
      # @param [Entity]
      # @return [Boolean]
      def accept?(entity)
        result = true
        arguments.each do |a|
          result = if a.is_a?(Symbol)
            (entity.send(a) != false)
          elsif a.is_a?(Regexp)
            !entity.to_s.match(a).nil?
          elsif a.is_a?(Module) || a.is_a?(Class)
            entity.is_a?(a)
          else
            (entity == a)
          end
          break if result == false
        end
        result
      end

      protected

      # Return an array of the entity's children. If the child is accessible,
      # recursively append its children.
      # The result will NOT include the original entity itself.
      #
      # @param [Entity]
      # @return [Array<Object>]
      def subquery_accessible entity
        return [] if entity.nil?
        result = []
        if entity.accessible?
          entity.children.each do |c|
            result.push c
            result.concat subquery_accessible(c)
          end
        end
        result
      end

      private

      def simplify_arguments
        arguments.map do |a|
          if a.is_a?(Class) || a.is_a?(Object)
            a.to_s.split('::').last.downcase
          else
            a.to_s.downcase
          end
        end
      end

      def nested?(token)
        !token.match(NEST_REGEXP).nil?
      end

      def denest(objects, token)
        parts = token.split(NEST_REGEXP)
        current = parts.pop
        last_result = objects.select { |e| e.specified?(current) }
        last_result = objects.select { |e| e.specified?(current, fuzzy: true) } if last_result.empty?
        until parts.empty?
          current = "#{parts.last} #{current}"
          result = last_result.select { |e| e.specified?(current) }
          result = last_result.select { |e| e.specified?(current, fuzzy: true) } if result.empty?
          break if result.empty?
          parts.pop
          last_result = result
        end
        return [] if last_result.empty? or last_result.length > 1
        return last_result if parts.empty?
        denest(last_result[0].children, parts.join(' '))
      end
    end
  end
end
