module Gamefic

  class Director
    @@disambiguator = Action.new nil, nil, Query::Base.new do |actor, entities|
      definites = []
      entities.each { |entity|
        definites.push entity.definitely
      }
      actor.tell "I don't know which you mean: #{definites.join_or}."
    end
    def self.dispatch(actor, *args)
      options = []
      if args.length > 1
        command = args.shift
        actions = actor.plot.commands[command.to_sym]
        actions.each { |action|
          if action.queries.length == args.length
            valid = true
            index = 0
            action.queries.each { |query|
              if query.validate(actor, args[index]) == false
                valid = false
                break
              end
              index += 1
            }
            if valid
              options.push [action, [actor] + args]
            end
          end
        }
        if options.length == 0
          args.unshift command
        end
      end
      if options.length == 0
        command = args.join(' ')
        command = command.to_s.strip
        if command.to_s == ''
          return
        end
        begin
          handlers = Syntax.match(command, actor.plot.syntaxes)
        rescue Exception => e
          puts "#{e}"
          return
        end
        handlers.each { |handler|
          actions = actor.plot.commands[handler[0]]
          if actions != nil
            actions.each { |action|
              if action.queries.length == 0 and handler.length > 1
                next
              end
              orders = bind_contexts_in_result(actor, handler, action)
              orders.each { |order|
                valid = true
                args = Array.new
                args.push actor
                invalid_argument = nil
                order.arguments.each { |a|
                  if a.length > 1
                    invalid_argument = a
                    valid = false
                    break
                  end
                  args.push a[0]
                }
                if valid
                  options.push [order.action, args]
                else
                  options.push [@@disambiguator, [actor, invalid_argument]]
                end
              }
            }
          end
        }
      end
      del = Delegate.new(actor, options, actor.plot.asserts, actor.plot.finishes)
      del.execute
    end
    private
    def self.bind_contexts_in_result(actor, handler, action)
      queries = action.queries.clone
      objects = self.execute_query(actor, handler[1..-1], queries, action)
      num_nil = 0
      while objects.length == 0 and queries.last.optional?
        num_nil +=1
        queries.pop
        objects = self.execute_query(actor, handler[1..-1], queries, action, num_nil)
      end
      return objects
    end
    def self.execute_query(actor, arguments, queries, action, num_nil = 0)
      prepared = Array.new
      objects = Array.new
      valid = true
      queries.clone.each { |context|
        arg = arguments.shift
        if arg == nil or arg == ''
          valid = false
          next
        end
        if context == String
          prepared.push [arg]
        elsif context.kind_of?(Query::Base)
          if arg == 'it' and actor.object_of_pronoun != nil
            result = context.execute(actor, "#{actor.object_of_pronoun.name}")
          else
            result = context.execute(actor, arg)
          end
          if result.objects.length == 0
            valid = false
            next
          else
            prepared.push result.objects
            if result.remainder
              arguments.push result.remainder
            end
          end
        else
          # TODO: Better message
          raise "Invalid object"
        end
      }
      if valid == true
        prepared.each { |p|
          p.uniq!
        }
        num_nil.times do
          prepared.push [nil]
        end
        objects.push Order.new(action, prepared)
      end
      objects
    end
  end
  
  class Director
    class Delegate
      @@assertion_stack = Array.new
      @@delegation_stack = Array.new
      def initialize(actor, actions, asserts, finishes)
        @actor = actor
        @actions = actions
        @asserts = asserts
        @finishes = finishes
      end
      def execute
        if @actor.is?(:debugging)
          @actor.tell "[DEBUG] Performing action"
        end
        befores = []
        afters = []
        @actions.each { |action|
          if action[0].kind_of?(Meta)
            befores.push action
          else
            afters.push action
          end
        }
        @@delegation_stack.push befores
        has_befores = (befores.length > 0)
        handle befores
        @@delegation_stack.pop
        if afters.length == 0 or (has_befores and afters[0][0].command == nil)
          return
        end
        @@assertion_stack.push Hash.new
        # Assertion of action is assumed true unless an assertion rule explicitly
        # returns false
        result = true
        @asserts.each { |key, rule|
          this_result = rule.test(@actor, @actions[0][0].command)
          if this_result == false
            if @actor.is?(:debugging)
              @actor.tell "[DEBUG] Asserting #{key} - defined at #{rule.caller}) - FALSE"
            end
            result = false
          else
            if @actor.is?(:debugging)
              @actor.tell "[DEBUG] Asserting #{key} - defined at #{rule.caller}) - TRUE"
            end
          end
        }
        if result == false
          return
        end
        @@delegation_stack.push afters
        handle afters
        @@delegation_stack.pop
        @actor.plot.finishes.each { |key, rule|
          rule.call(@actor)
        }
      end
      def handle options
        if options.length > 0
          opt = options.shift
          if opt[1][0].is?(:debugging)
            opt[1][0].tell "[DEBUG] Executing #{opt[0].class}: #{opt[0].signature} - defined at #{opt[0].caller})"
          end
          if opt[1].length == 1
            opt[0].execute(opt[1][0])
            opt[1][0].object_of_pronoun = nil
          else
            if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
              opt[1][0].object_of_pronoun = opt[1][1]
            elsif opt[1][0].parent == opt[1][1]
              opt[1][0].object_of_pronoun = nil
            end
            opt[0].execute(opt[1])
          end
        end
      end
      def self.next_command
        return nil if @@delegation_stack.last.nil? or @@delegation_stack.last[0].length == 0
        return @@delegation_stack.last[0][0].command
      end
      def self.passthru
        if @@delegation_stack.last != nil
          if @@delegation_stack.last.length > 0
            opt = @@delegation_stack.last.shift
            if opt[1][0].is?(:debugging)
              opt[1][0].tell "[DEBUG] Executing #{opt[0].class}: #{opt[0].signature} - defined at #{opt[0].caller})"
            end
            if opt[1].length == 1
              opt[0].execute(opt[1][0])
              opt[1][0].object_of_pronoun = nil
            else
              if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
                opt[1][0].object_of_pronoun = opt[1][1]
              elsif opt[1][0].parent == opt[1][1]
                opt[1][0].object_of_pronoun = nil
              end
              opt[0].execute(opt[1])
            end
          end
        end
      end
    end
    class Order
      attr_reader :action, :arguments
      def initialize(action, arguments)
        @action = action
        @arguments = arguments
      end
    end
  end

end
