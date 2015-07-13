module Gamefic

  class Director
    autoload :Parser, 'gamefic/director/parser'
    autoload :Delegate, 'gamefic/director/delegate'
    autoload :Order, 'gamefic/director/order'
    
    def self.dispatch(actor, *args)
      orders = []
      if args.length > 1
        orders = Parser.from_tokens(actor, args)
      end
      if orders.length == 0
        orders = Parser.from_string(actor, args.join(' ').strip)
      end
      first_order = orders[0]
      del = Delegate.new(actor, orders)
      del.execute
      first_order
    end
  end

end
