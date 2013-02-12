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
		if args.length == 1
			send(:private_execute, args[0])
		else
			send(:private_execute, args)
		end
	end
	def self.dispatch(actor, command)
		command.strip!
		results = Parser.parse(command)
		results.each { |result|
			worked = bind_contexts_in_result(actor, result)
			if worked != nil
				args = Array.new
				args.push actor
				worked.each { |w|
					if w.kind_of?(Array)
						if w.length > 1
							actor.tell "I don't know which you mean: #{w.join(', ')}"
							return
						else
							args.push w[0]
						end
					else
						args.push w
					end
				}
				del = Delegate.new(result.action.proc)
				del.execute(args)
				if del.passthru? == false
					return
				end
			end
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
	def self.bind_contexts_in_result(actor, result)
		objects = Array.new
		arguments = result.arguments
		result.action.contexts.each { |context|
			arg = arguments.shift
			if arg == nil or arg == ''
				return nil
			end
			bind = context.match(actor, arg)
			if bind.objects.length == 0
				return nil
			end
			if arguments.length == 0
				arguments.push bind.remainder
			end
			objects.push bind.objects
		}
		return objects
	end
end
