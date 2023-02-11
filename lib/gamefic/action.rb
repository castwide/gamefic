module Gamefic
  class Action
    # @return [Gamefic::Actor]
    attr_reader :actor

    # An array of objects on which the action will operate, e.g., an entity
    # that is a direct object of a command.
    #
    # @return [Array<Object>]
    attr_reader :arguments
    alias parameters arguments

    # @param actor [Gamefic::Actor]
    # @param arguments [Array<Object>]
    def initialize actor, arguments, with_callbacks = false
      @actor = actor
      @arguments = arguments
      @executed = false
      @with_callbacks = with_callbacks
    end

    # Perform the action.
    #
    def execute
      return if @cancelled
      run_before_actions
      return if @cancelled
      self.class.executor.call(@actor, *arguments) unless self.class.executor.nil?
      @executed = true
      run_after_actions
    end

    # Cancel an action. This method can be called in a before_action hook to
    # prevent subsequent hooks and the action itself from being executed.
    # Cancelling an action in an after_action hook has no effect.
    #
    def cancel
      # @todo Emit a warning for attempts to cancel an action after it's been
      #   executed
      @cancelled = true
    end

    # True if the #execute method has been called for this action.
    #
    # @return [Boolean]
    def executed?
      @executed
    end

    def cancelled?
      !@executed && @cancelled
    end

    # The verb associated with this action.
    #
    # @return [Symbol] The symbol representing the verb
    def verb
      self.class.verb
    end

    def signature
      self.class.signature
    end

    def rank
      self.class.rank
    end

    # True if the action is flagged as meta.
    #
    # @return [Boolean]
    def meta?
      self.class.meta?
    end

    # @param verb [Symbol]
    # @param queries [Array<Gamefic::Query::Base>]
    # @param meta [Boolean]
    # @return [Class<Action>]
    def self.subclass verb, *queries, meta: false, &block
      act = Class.new(self) do
        self.verb = verb
        self.meta = meta
        queries.each do |q|
          add_query q
        end
        on_execute &block
      end
      if !block.nil? && act.queries.length + 1 != block.arity && block.arity > 0
        raise ArgumentError.new("Number of parameters is not compatible with proc arguments")
      end
      act
    end

    private

    def run_before_actions
      return unless @with_callbacks
      @actor.playbooks
            .flat_map(&:before_actions)
            .each do |hook|
              next unless hook.verb.nil? || hook.verb == verb
              hook.block.call(self)
              break if @cancelled
            end
    end

    def run_after_actions
      return unless @with_callbacks
      @actor.playbooks
            .flat_map(&:after_actions)
            .each do |hook|
              next unless hook.verb.nil? || hook.verb == verb
              hook.block.call(self)
            end
    end

    class << self
      attr_reader :verb

      # The proc to call when the action is executed
      #
      # @return [Proc]
      attr_reader :executor

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
        "#{verb} #{queries.map {|m| m.signature}.join(', ')}"
      end

      # True if this action is not intended to be performed directly by a
      # character.
      # If the action is hidden, users should not be able to perform it with a
      # direct command. By default, any action whose verb starts with an
      # underscore is hidden.
      #
      # @return [Boolean]
      def hidden?
        verb.to_s.start_with?('_')
      end

      # @return [Integer]
      def rank
        if @rank.nil?
          @rank = 0
          queries.each do |q|
            @rank += (q.rank + 1)
          end
          @rank -= 1000 if verb.nil?
        end
        @rank
      end

      def valid? actor, objects
        return false if objects.length != queries.length
        queries.each_with_index do |p, i|
          return false unless p.include?(actor, objects[i])
        end
        true
      end

      # Return an instance of this Action if the actor can execute it with the
      # provided tokens, or nil if the tokens are invalid.
      #
      # @param action [Gamefic::Entity]
      # @param command [Command]
      # @return [self, nil]
      def attempt actor, command, with_callbacks = false
        return nil if command.verb != verb
        tokens = command.arguments
        result = []
        matches = Gamefic::Query::Matches.new([], '', '')
        queries.each_with_index do |p, i|
          return nil if tokens[i].nil? && matches.remaining == ''
          matches = p.resolve(actor, "#{matches.remaining} #{tokens[i]}".strip, continued: (i < queries.length - 1))
          return nil if matches.objects.empty?
          accepted = matches.objects.select { |o| p.accept?(o) }
          return nil if accepted.empty?
          if p.ambiguous?
            result.push accepted
          else
            return nil if accepted.length != 1
            result.push accepted.first
          end
        end
        new(actor, result, with_callbacks)
      end

      protected

      attr_writer :verb

      attr_writer :meta
    end
  end
end
