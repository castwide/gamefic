module Gamefic
  module Query
    class Base
      NEST_REGEXP = / in | on | of | from | inside /

      attr_reader :arguments

      def initialize *args
        @arguments = args
      end

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

      # Get an array of objects that exist in the subject's context and match
      # the provided token.
      #
      def resolve(subject, token, continued: false)
        available = context_from(subject)
        return Matches.new([], '', token) if available.empty?
        if continued
          return Matches.execute(available, token, continued: continued)
        elsif nested?(token)
          drill = denest(available, token)
          drill.keep_if{ |e| accept?(e) }
          return Matches.new(drill, token, '') unless drill.length != 1
          return Matches.new([], '', token)
        end
        result = available.select{ |e| e.match?(token) }
        result = available.select{ |e| e.match?(token, fuzzy: true) } if result.empty?
        result.keep_if{ |e| accept? e }
        Matches.new(result, (result.empty? ? '' : token), (result.empty? ? token : ''))
      end

      def include?(subject, object)
        return false unless accept?(object)
        result = context_from(subject)
        result.include?(object)
      end

      def magnification
        1
      end

      def precision
        if @precision.nil?
          @precision = 1
          arguments.each { |a|
            if a.kind_of?(Symbol) or a.kind_of?(Regexp)
              @precision += 1
            elsif a.kind_of?(Class)
              @precision += (count_superclasses(a) * 100)
            elsif a.kind_of?(Module)
              @precision += 10
            elsif a.kind_of?(Object)
              @precision += 1000
            end
          }
          @precision
        end
        @precision
      end

      def rank
        (magnification * 100) + precision
      end

      def signature
        "#{self.class.to_s.downcase}(#{@arguments.join(',')})"
      end

      def accept?(entity)
        result = true
        arguments.each { |a|
          if a.kind_of?(Symbol)
            result = (entity.send(a) != false)
          elsif a.kind_of?(Regexp)
            result = (!entity.to_s.match(a).nil?)
          elsif a.is_a?(Module) or a.is_a?(Class)
            result = (entity.is_a?(a))
          else
            result = (entity == a)
          end
          break if result == false
        }
        result
      end

      protected
      
      # Return an array of the entity's children. If the child is neighborly,
      # recursively append its children.
      # The result will NOT include the original entity itself.
      #
      # @return [Array<Object>]
      def subquery_accessible entity
        result = []
        if entity.accessible?
          entity.children.each { |c|
            result.push c
            result.concat subquery_accessible(c)
          }
        end
        result
      end

      private

      def count_superclasses cls
        s = cls.superclass
        c = 1
        until s.nil? or s == Object or s == BasicObject
          c += 1
          s = s.superclass
        end
        c
      end

      def nested?(token)
        !token.match(NEST_REGEXP).nil?
      end

      def denest(objects, token)
        parts = token.split(NEST_REGEXP)
        current = parts.pop
        last_result = objects.select{ |e| e.match?(current) }
        last_result = objects.select{ |e| e.match?(current, fuzzy: true) } if last_result.empty?
        result = last_result
        while parts.length > 0
          current = "#{parts.last} #{current}"
          result = last_result.select{ |e| e.match?(current) }
          result = last_result.select{ |e| e.match?(current, fuzzy: true) } if result.empty?
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
