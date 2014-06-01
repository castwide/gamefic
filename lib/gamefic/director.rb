module Gamefic

	class Director
		def self.dispatch(actor, command)
			command.strip!
      if command.to_s == ''
        return
      end
      begin
        handlers = Syntax.match(command, actor.plot)
      rescue Exception => e
        puts "#{e}"
        return
      end
      befores = Array.new
			options = Array.new
			handlers.each { |handler|
				actions = actor.plot.commands[handler.command]
				if actions != nil
					actions.each { |action|
            if action.queries.length == 0 and handler.arguments.length > 0
              next
            end
						orders = bind_contexts_in_result(actor, handler, action)
						orders.each { |order|
							args = Array.new
							args.push actor
							order.arguments.each { |a|
								if a.length > 1
									longnames = Array.new
									a.each { |b|
										longnames.push "#{b.definitely}"
									}
									actor.tell "I don't know which you mean: #{longnames.join_and(', ', ' or ')}."
									return
								end
								args.push a[0]
							}
              if order.action.kind_of?(Before)
                befores.push [order.action, args]
              else
                options.push [order.action, args]
              end
						}
					}
				end
			}
			del = Delegate.new(actor, befores, options)
			del.execute
		end
		private
		def self.bind_contexts_in_result(actor, handler, action)
      queries = action.queries.clone
      objects = self.execute_query(actor, handler.arguments.clone, queries, action)
      num_nil = 0
      while objects.length == 0 and queries.last.optional?
        num_nil +=1
        queries.pop
        objects = self.execute_query(actor, handler.arguments.clone, queries, action, num_nil)
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
			def initialize(actor, befores, actions)
        @actor = actor
        @befores = befores
				@actions = actions
			end
			def execute
        @@assertion_stack.push Hash.new
        @@delegation_stack.push @befores
        handle @befores
        @@delegation_stack.pop
        if @@assertion_stack.last[:everything] == false
          @@assertion_stack.pop
          return
        end
        result = true
        @@delegation_stack.push @actions
        # Nil commands pass assertions to facilitate error messages.
        if @@assertion_stack.last[:everything] != true and Director::Delegate.next_command != nil
          @actor.plot.rules.each { |k, v|
            if @@assertion_stack.last[k] == true
              next
            elsif @@assertion_stack.last[k] == false
              result = false
              break
            end
            result = v.test(@actor)
            if result == false
              break
            end
            result = true
          }
        end
        @@assertion_stack.pop
        if result == true
          handle @actions
        end
        @@delegation_stack.pop
			end
      def handle options
				if options.length > 0
					opt = options.shift
					if opt[1].length == 1
						opt[0].execute(opt[1][0])
					else
            if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
              opt[1][0].object_of_pronoun = opt[1][1]
            else
              opt[1][0].object_of_pronoun = nil
            end
						opt[0].execute(opt[1])
					end
				end
      end
      def self.pass requirement
        @@assertion_stack.last[requirement] = true
      end
      def self.deny requirement
        @@assertion_stack.last[requirement] = false
      end
      def self.next_command
        return nil if @@delegation_stack.last.nil? or @@delegation_stack.last[0].length == 0
        return @@delegation_stack.last[0][0].command
      end
			def self.passthru
				if @@delegation_stack.last != nil
					if @@delegation_stack.last.length > 0
						opt = @@delegation_stack.last.shift
						if opt[1].length == 1
							opt[0].execute(opt[1][0])
						else
              if opt[1].length == 2 and opt[1][1].kind_of?(Entity) and opt[1][0].parent != opt[1][1]
                opt[1][0].object_of_pronoun = opt[1][1]
              else
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
