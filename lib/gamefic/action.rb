module Gamefic
  # Exception raised when the Action's proc arity is not compatible with the
  # number of queries
  class ActionArgumentError < ArgumentError
  end

  class Action
    def initialize actor, parameters
      @actor = actor
      @parameters = parameters
    end

    def execute
      self.class.executor.call(@actor, *@parameters) unless self.class.executor.nil?
    end

    def signature
      self.class.signature
    end

    def rank
      self.class.rank
    end

    def meta?
      self.class.meta?
    end

    def self.subclass verb, *queries, meta: false, &block
      act = Class.new(self) do
        self.verb = verb
        self.meta = meta
        queries.each { |q|
          add_query q
        }
        on_execute &block
      end
      if !block.nil? and queries.length + 1 != block.arity and block.arity > 0
        raise ActionArgumentError.new("Number of parameters is not compatible with proc arguments")
      end
      act
    end

    class << self
      def verb
        @verb
      end

      def meta?
        @meta ||= false
      end

      def add_query q
        @specificity = nil
        queries.push q
      end

      def queries
        @queries ||= []
      end

      def on_execute &block
        @executor = block
      end

      def signature
        # @todo This is clearly unfinished
        "#{verb} #{queries.map{|m| m.signature}.join(',')}"
      end

      def executor
        @executor
      end

      def rank
        #if @specificity.nil?
          @rank = 0
          queries.each { |q|
            @rank += (q.rank + 1)
          }
          @rank -= 1000 if verb.nil?
        #end
        #puts "Got specificity for #{signature} #{@specificity} on #{queries.length}"
        @rank
      end

      def valid? actor, objects
        return false if objects.length != queries.length
        i = 0
        queries.each { |p|
          return false unless p.include?(actor, objects[i])
          i += 1
        }
        true
      end

      def attempt actor, tokens
        i = 0
        result = []
        queries.each { |p|
          return nil if tokens[i].nil?
          available = p.resolve(actor, tokens[i])
          return nil if available.empty?
          if p.ambiguous?
            result.push available
          else
            return nil if available.length > 1
            result.push available[0]
          end
          i += 1
        }
        self.new(actor, result)
      end

      protected

      def verb= sym
        @verb = sym
      end

      def meta= bool
        @meta = bool
      end
    end
  end
end
