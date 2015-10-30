module Gamefic

  class Action
    attr_reader :order_key, :queries
    attr_writer :meta
    @@order_key_seed = 0
    def initialize(story, command, *queries, &proc)
      if !command.kind_of?(Symbol)
        command = command.to_s
        command = nil if command == ''
      end
      @plot = story
      @order_key = @@order_key_seed
      @@order_key_seed += 1
      @proc = proc
      if (command.kind_of?(Symbol) == false and !command.nil?)
        raise "Action commands must be symbols"
      end
      if !@proc.nil?
        if (queries.length + 1 != @proc.arity) and (queries.length == 0 and @proc.arity != -1)
          raise "Number of queries is not compatible with proc arguments"
        end
      end
      @command = command
      @queries = queries
      if !story.nil?
        story.send :add_action, self
      end
    end
    def block
      @proc
    end
    def specificity
      spec = 0
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
    def verb
      @command
    end
    def command
      @command
    end
    def key
      @key
    end
    def execute *args
      @proc.call(*args)
    end
    def signature
      sig = ["#{@command}"]
      @queries.each { |q|
        sig.push q.signature
      }
      sig.join(', ').gsub(/Gamefic::(Query::)?/, '')
    end
    def meta?
      @meta ||= false
    end
    private
      def self.explode(entity)
        arr = Array.new
        arr.push entity
        cls = entity.class
        while cls != Object
          arr.push cls
          cls = cls.superclass
        end
        arr.push String
        arr.push nil
      end
  end

end
