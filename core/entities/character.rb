class Character < Entity
	def is_are
		@name.downcase == 'you' ? 'are' : 'is'
	end
	def perform(command)
		command.strip!
		results = Parser.parse(command)
		worked = nil
		results.each { |result|
			worked = bind_contexts_in_result(result)
			if worked != nil
				worked.unshift self
				if worked.length == 1
					result.action.proc.call(worked[0])
				else
					result.action.proc.call(worked)
				end
				return
			end
		}
		self.tell "I don't know what you mean by '#{command}.'"
	end
	def bind_contexts_in_result(result)
		objects = Array.new
		arguments = result.arguments
		result.action.contexts.each { |context|
			arg = arguments.shift
			if arg == nil or arg == ''
				return nil
			end
			bind = context.match(self, arg)
			if bind.objects.length == 0
				return nil
			end
			if arguments.length == 0
				arguments.push bind.remainder
			end
			objects.push bind.objects[0]
		}
		return objects
	end
	def execute(command, target, tool, target_text = '', tool_text = '')
		if command == nil
			return
		end
		act = Action.find(command, target, tool, self.parent)
		if act != nil
			if act.key[1] == String
				target = target_text
			end
			if act.key[2] == String
				tool = tool_text
			end
			act.perform(self, target, tool)
			return true
		end
		return false
	end
	def	self.evaluate(this, proc, args)
		proc.call(*args)
	end
end

class Context
	NEIGHBOR = Context.new("person", [[:parent, :children], Character])
end
