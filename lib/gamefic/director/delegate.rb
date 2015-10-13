module Gamefic
  module Director
    class Delegate
      def initialize(actor, orders)
        @actor = actor
        @orders = orders
      end
      def proceed
        order = @orders.shift
        return if order.nil?
        @actor.send(:delegate_stack).push self
        # The actor is always the first argument to an Action proc
        arguments = order.arguments.clone
        arguments.unshift @actor
        order.action.execute(*arguments)
        @actor.send(:delegate_stack).pop
      end
      def execute
        return if @orders.length == 0
        if !@orders[0].action.kind_of?(Meta)
          @actor.plot.asserts.each_pair { |name, rule|
            result = rule.test(@actor, @orders[0].action.verb, @orders[0].arguments)
            if result == false
              return
            end
          }
        end
        proceed
      end
    end
  end
end
