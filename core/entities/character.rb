class Character < Entity
	def is_are
		@name.downcase == 'you' ? 'are' : 'is'
	end
	def perform(command)
		orig = command
		tokens = Array.new
		woids = command.strip.split
		words_to_tokenize = woids[1, woids.length - 1]
		currentMatches = nil
		words_to_tokenize.each { |w|
			puts "Checking #{w}"
			matches = self.children.matching(w) + self.parent.children.matching(w)
			if currentMatches == nil
				currentMatches = matches
			else
				compare = currentMatches.clone
				compare.delete_if { |m|
					matches.include?(m) == false
				}
				if compare.length == 0
					tokens.push currentMatches
					currentMatches = matches
				end
			end
		}
		if currentMatches != nil and currentMatches.length > 0
			tokens.push currentMatches
		end
		tokens.each { |t|
			t.each { |o|
				puts "#{o}"
			}
		}
		parser_result = Parser.actions(command.strip)
		if parser_result == nil or parser_result.length == 0
			self.tell "I don't know what you mean by '#{command.strip}.'"
			return
		end
		context_results = Array.new
		sentence = words_to_tokenize.join(' ')
		parser_result.each { |a|
			puts "From Character: #{a.tokens.join('|')}, #{a.tokens.length}"
			arguable = Array.new
			cr = nil
			keywords = a.tokens
			must_reach = a.action.contexts.length
			reached = 0
			a.action.contexts.each { |c|
				if keywords.length == 0
					break
				end
				cur_words = keywords.shift
				cr = c.match(self, cur_words)
				puts "Found #{cr.objects.length} matches with a remainder of #{cr.remainder}"
				arguable.push cr.objects
				if keywords.length == 0 and cr.remainder != ''
					keywords = [cr.remainder]
				end
				reached = reached + 1
			}
			if reached < must_reach
				puts "Did not finish finding tokens, got #{reached} of #{must_reach}."
			else
				puts "This might be executable!"
				arguments = Array.new
				arguable.each { |arg|
					if arg.length == 1
						arguments.push arg[0]
					else
						puts "Can't run this one.. #{arg} has ambiguities."
					end
				}
				if arguments.length == must_reach
					puts "And it is! Run this baby: #{a.action.key}"
					arguments.unshift(self)
					puts "#{arguments.length} arguments..."
					if (arguments.length == 1)
						a.action.proc.call(arguments[0])
					else
						a.action.proc.call(*arguments)
					end
					puts "Done"
					return
				end
			end
		}
		return
		if parts == nil or parts[0] == nil
			# Tell the actor there was a problem
			self.tell "I don't know what you mean by '#{command.strip}.'"
			return
		end
		command = parts[0]
		target = parts[1]
		tool = parts[2]
		target = self.children.matching(target) + self.parent.children.matching(target)
		if target.length > 1
			self.tell "'#{parts[1].to_s.cap_first}' might refer to any of the following: #{target.join(", ")}"
			return
		elsif target.length == 1
			target = target[0]
		else
			target = parts[1]
		end
		tool = self.children.matching(tool) + self.parent.children.matching(tool)
		if tool.length > 1
			self.tell "'#{parts[2].to_s.cap_first}' might refer to any of the following: #{tool.join(", ")}"
			return
		elsif tool.length == 1
			tool = tool[0]
		else
			tool = parts[2]
		end
		if execute(command, target, tool, parts[1], parts[2]) == false
			self.tell "I don't know what you mean by '#{orig.strip}.'"
		end
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
	NEIGHBOR = Context.new("person", [:parent, Character])
end
