module Gamefic

	class Delegate
		@@stack = Array.new
		def initialize(proc)
			implement(proc)
			@passthru = false
		end
		def passthru
			@passthru = true
		end
		def passthru?
			@passthru
		end
		def execute(args)
			@passthru = false
			if args.length == 1
				send(:private_execute, args[0])
			else
				send(:private_execute, args)
			end
		end
		def self.dispatch(actor, command)
			command.strip!
			results = Parser.parse(command)
			results.each { |statement|
				orders = bind_contexts_in_result(actor, statement)
				orders.each { |order|
					args = Array.new
					args.push actor
					order.arguments.each { |a|
						if a.length > 1
							actor.tell "I don't know which you mean: #{a.join(', ')}"
							return
						else
							args.push a[0]
						end
					}
					del = Delegate.new(order.action.proc)
					del.execute(args)
					if del.passthru? == false
						return
					end
				}
			}
			actor.tell "I don't know what you mean by '#{command}.'"
		end
		private
		def implement(proc)
			self.class.send(:define_method, :private_execute, proc)
			class << self
				private :private_execute
			end
		end
		class Order
			attr_reader :action, :arguments
			def initialize(action, arguments)
				@action = action
				@arguments = arguments
			end
		end
		def self.bind_contexts_in_result(actor, statement)
			objects = Array.new
			Action.actions_for(statement.command).each { |action|
				valid = true
				prepared = Array.new
				arguments = statement.arguments.clone
				action.contexts.each { |context|
					arg = arguments.shift
					if arg == nil or arg == ''
						valid = false
						next
					end
					bind = context.match(actor, arg)
					if bind.objects.length == 0
						valid = false
						next
					end
					if arguments.length == 0
						arguments.push bind.remainder
					end
					prepared.push bind.objects
				}
				if valid == true
					objects.push Order.new(action, prepared)
				end
			}
			return objects
		end
	end

end
