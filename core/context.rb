class Context
	class Response
		attr_reader :objects, :remainder
		def initialize(objects, remainder)
			@objects = objects
			@remainder = remainder
		end
	end
	attr_reader :description, :arguments
	def initialize(description, arguments)
		@description = description
		@arguments = arguments
	end
	def match(subject, keywords)
		results = Entity.empty
		if keywords == nil
			return Response.new(results, '')
		end
		@arguments.each { |arg|
			if arg == String
				return Response.new([keywords], '')
			elsif arg.class == Class or arg.class == Module
				results = results.that_are(arg)
			elsif arg.kind_of? Symbol
				if subject.respond_to? arg
					results.concat(subject.method(arg).call)
				else
					raise "Bad symbol"
				end
			elsif arg.kind_of? Array
				current = subject
				arg.each { |sub_arg|
					if current.respond_to? sub_arg
						current = current.method(sub_arg).call
					else
						raise "Bad symbol"
					end
				}
				results.concat(current)
			else
				raise "I don't know what #{arg} is."
			end
		}
		passed = keywords.split
		accepted = 0
		keywords.split.each { |word|
			if word.length > 1 and word != 'the'
				currentMatches = results.matching(word)
				if currentMatches.length == 0
					if accepted == 0
						results = Entity.empty
					end
					break
				else
					accepted = accepted + 1
					results = currentMatches
				end
			else
				puts "Skipping #{word}: not accepted."
			end
			passed.shift
		}
		Response.new(results, passed.join(' '))
	end
	STRING = Context.new("text", [String])
	CHILDREN = Context.new("my_thing", [:children])
	PARENT = Context.new("thing_in_room", [[:parent, :children]])
	ENVIRONMENT = Context.new("thing", [:children, [:parent, :children]])
	ANYWHERE = Context.new("thing_anywhere", [Object])
end
