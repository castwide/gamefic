module Gamefic
  module Director
    class Delegate
      # If we use Query::Base.new in the @disambiguator declaration, Opal
      # passes the block to the query instead of the action.
      base = Query::Base.new
      @@disambiguator = Action.new nil, nil, base do |actor, entities|
        definites = []
        entities.each { |entity|
          definites.push entity.definitely
        }
        actor.tell "I don't know which you mean: #{definites.join_or}."
      end
      @@disambiguator.meta = true
      def initialize(actor, orders)
        @actor = actor
        @orders = orders
      end
      def proceed
        return if @orders.length == 0
        @actor.send(:delegate_stack).push self
        executed = false
        while !executed
          order = @orders.shift
          break if order.nil?
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
              order = Order.new(@actor, @@disambiguator, [])
              final_arguments = [ambiguous]
              break
            end
            valid = []
            argument.each { |m|
              if order.action.queries[arg_i].allow_many?
                if m.kind_of?(Array)
                  arg_array = []
                  if m.length > 1
                    order = Order.new(@actor, @@disambiguator, [])
                    final_arguments = [m]
                    break
                  elsif order.action.queries[arg_i].validate(@actor, m[0])
                    arg_array.push m[0]
                  else
                    final_arguments = nil
                    break
                  end
                  if order.action == @@disambiguator or final_arguments.nil?
                    break
                  end
                  valid.push arg_array
                else
                  final_arguments = nil
                  break
                end
              else
                if order.action.queries[arg_i].validate(@actor, m)
                  valid.push m
                else
                  final_arguments = nil
                  break
                end
              end
            }
            if order.action == @@disambiguator or final_arguments.nil?
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
        end
        @actor.send(:delegate_stack).pop
      end
      def execute
        return if @orders.length == 0
        if !@orders[0].action.meta?
          @actor.plot.asserts.each_pair { |name, rule|
            result = rule.test(@actor, @orders[0].action.verb, @orders[0].arguments)
            if result == false
              return
            end
          }
        end
        proceed
      end
      private
    end
  end
end
