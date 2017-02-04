module Gamefic

  module Director
    autoload :Parser, 'gamefic/director/parser'
    autoload :Delegate, 'gamefic/director/delegate'
    autoload :Order, 'gamefic/director/order'
    
    def self.dispatch(playbook, actor, *args)
      orders = []
      if args.length > 1
        orders = Parser.from_tokens(playbook, actor, args)
      end
      if orders.length == 0
        orders = Parser.from_string(playbook, actor, args.join(' ').strip)
      end
      first_order = orders[0]
      del = Delegate.new(actor, orders)
      del.execute
      first_order
    end
  end

end
