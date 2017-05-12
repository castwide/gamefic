module Gamefic
  # Exception raised when the Action's proc arity is not compatible with the
  # number of queries
  class ActionArgumentError < ArgumentError
  end

  class Action
    attr_reader :parameters

    def initialize actor, parameters
      @actor = actor
      @parameters = parameters
      @executed = false
    end

    # @todo Determine whether to call them parameters, arguments, or both.
    def arguments
      parameters
    end

    def execute
      @executed = true
      self.class.executor.call(@actor, *@parameters) unless self.class.executor.nil?
    end

    def executed?
      @executed
    end

    def verb
      self.class.verb
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

    def order_key
      self.class.order_key
    end

    def self.subclass verb, *q, meta: false, order_key: 0, &block
      act = Class.new(self) do
        self.verb = verb
        self.meta = meta
        self.order_key = order_key
        q.each { |q|
          add_query q
        }
        on_execute &block
      end
      if !block.nil? and act.queries.length + 1 != block.arity and block.arity > 0
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

      def hidden?
        verb.to_s.start_with?('_')
      end

      def executor
        @executor
      end

      def order_key
        @order_key ||= 0
      end

      def rank
        if @rank.nil?
          @rank = 0
          queries.each { |q|
            @rank += (q.rank + 1)
          }
          @rank -= 1000 if verb.nil?
        end
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
        matches = Gamefic::Query::Matches.new([], '', '')
        queries.each { |p|
          return nil if tokens[i].nil? and matches.remaining == ''
          matches = p.resolve(actor, "#{matches.remaining} #{tokens[i]}".strip, continued: (i < queries.length - 1))
          return nil if matches.objects.empty?
          if p.ambiguous?
            result.push matches.objects
          else
            return nil if matches.objects.length > 1
            result.push matches.objects[0]
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

      def order_key= num
        @order_key = num
      end
    end
  end
end
