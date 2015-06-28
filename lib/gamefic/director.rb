module Gamefic

  class Director
    autoload :Parser, 'gamefic/director/parser'
    autoload :Delegate, 'gamefic/director/delegate'
    
    def self.dispatch(actor, *args)
      options = []
      if args.length > 1
        options = Parser.from_tokens(actor, args)
      end
      if options.length == 0
        options = Parser.from_string(actor, args.join(' ').strip)
      end
      #del = Delegate.new(actor, options, actor.plot.asserts, actor.plot.finishes)
      del = Delegate.new(actor, options)
      del.execute
    end
  end

end
