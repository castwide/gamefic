require 'gamefic/director/parser'
require 'gamefic/director/delegate'

module Gamefic

  class Director
    # TODO: The autoload method breaks Web platform builds.
    #autoload :Parser, 'gamefic/director/parser'
    #autoload :Delegate, 'gamefic/director/delegate'
    
    def self.dispatch(actor, *args)
      options = []
      if args.length > 1
        options = Parser.from_tokens(actor, args)
      end
      if options.length == 0
        options = Parser.from_string(actor, args.join(' ').strip)
      end
      del = Delegate.new(actor, options, actor.plot.asserts, actor.plot.finishes)
      del.execute
    end
  end

end
