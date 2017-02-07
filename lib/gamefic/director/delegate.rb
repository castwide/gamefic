module Gamefic
  module Director
    class Delegate

      class << self
        def proceed_for actor
          return if stack_map[actor].nil?
          stack_map[actor].last.proceed unless stack_map[actor].last.nil?
        end

        private

        def stack_map
          @stack_map ||= {}
        end
      end

      def initialize(actor, orders)
        @actor = actor
        @orders = orders
        @did = []
      end

      def proceed
        return if @orders.length == 0
        executed = false
        while !executed
          order = @orders.shift
          break if order.nil?
          # HACK: Make sure Character#proceed does not repeat an action
          next if @did.include?(order.action)
          @did.push order.action
          @last_action = order.action
          executed = attempt(order)
        end
      end

      def execute
        return if @orders.length == 0
        unless @orders[0].action.meta?
          @actor.playbook.assertions.each { |a|
            a.call @orders[0]
            return if @orders[0].canceled?
          }
        end
        stack_map[@actor] ||= []
        stack_map[@actor].push self
        proceed
        stack_map[@actor].pop
        stack_map.delete @actor if stack_map[@actor].empty?
      end

      private

      def attempt order
        executed = false
        arg_i = 0
        final_arguments = []
        order.arguments.each { |argument|
          if argument.length > 1 and !order.action.queries[arg_i].allow_many?
            if argument[0].kind_of?(Array)
              # This thing refers to multiple items. Just keep going.
              final_arguments = nil
              break
            else
              ambiguous = argument
            end
            order = Order.new(@actor, @actor.playbook.disambiguator, [])
            final_arguments = [ambiguous]
            break
          end
          if order.action.queries[arg_i].allow_ambiguous?
            valid = argument.flatten
          else
            valid = validate(argument, arg_i, order)
            if valid.nil?
              final_arguments = nil
              break
            end
          end
          if order.action == @actor.playbook.disambiguator or final_arguments.nil?
            break
          end
          if order.action.queries[arg_i].allow_many?
            final_arguments.push valid.flatten
          elsif valid.length == 1
            final_arguments.push valid[0]
          else
            final_arguments = nil
            break
          end
          arg_i += 1
        }
        if !final_arguments.nil?
          # The actor is always the first argument to an Action proc
          final_arguments.unshift @actor
          order.action.execute(*final_arguments)
          executed = true
        end
        executed
      end

      def validate argument, arg_i, order
        valid = []
        argument.each { |m|
          if order.action.queries[arg_i].validate(@actor, m)
            valid.push m
          else
            valid = nil
            break
          end
        }
        valid
      end

      private

      def stack_map
        Delegate.send(:stack_map)
      end
    end
  end
end
