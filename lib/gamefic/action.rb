module Gamefic

  # Actions manage the execution of commands that Characters can perform.
  # 
  class Action
    attr_reader :order_key, :queries
    attr_writer :meta
    @@order_key_seed = 0
    
    def initialize(plot, verb, *queries, &proc)
      if !verb.kind_of?(Symbol)
        verb = verb.to_s
        verb = nil if verb == ''
      end
      @plot = plot
      @order_key = @@order_key_seed
      @@order_key_seed += 1
      @proc = proc
      if (verb.kind_of?(Symbol) == false and !verb.nil?)
        raise "Action verbs must be symbols"
      end
      if !@proc.nil?
        if (queries.length + 1 != @proc.arity) and (queries.length == 0 and @proc.arity != -1)
          raise "Number of queries is not compatible with proc arguments"
        end
      end
      @verb = verb
      @queries = queries
      if !plot.nil?
        plot.send :add_action, self
      end
    end
    
    # Get the specificity of the Action.
    # Specificity indicates how narrowly the Action's queries filter matches.
    # Actions with higher specificity are given higher priority when searching
    # for the Action that matches a character command. For example, an Action
    # with a Query that filters for a specific class of Entity has a higher
    # specificity than an Action with a Query that accepts arbitrary text.
    #
    # @return [Fixnum]
    def specificity
      spec = 0
      if verb.nil?
        spec = -100
      end
      magnitude = 1
      @queries.each { |q|
        if q.kind_of?(Query::Base)
          spec += (q.specificity * magnitude)
        else
          spec += magnitude
        end
        #magnitude = magnitude * 10
      }
      return spec
    end
    
    # Get the verb associated with this Action.
    # The verb is represented by a Symbol in the imperative form, such as
    # :take or :look_under.
    #
    # @return [Symbol] The Symbol representing the verb.
    def verb
      @verb
    end
    
    # Execute this Action. This method is typically called by the Plot when
    # a Character performs a command.
    def execute *args
      @proc.call(*args)
    end
    
    def signature
      sig = ["#{@verb}"]
      @queries.each { |q|
        sig.push q.signature
      }
      "#{sig.join(', ').gsub(/Gamefic::(Query::)?/, '')}(#{specificity})"
    end
    
    # Is this a meta Action?
    # If an Action is flagged meta, it usually means that it provides
    # information about the game or manages some aspect of the user interface.
    # It shouldn't represent an Action that the player's character performs in
    # the game world. Examples include Actions to display credits or
    # instructions.
    #
    # @return [Boolean]
    def meta?
      @meta ||= false
    end
    
  end

end
