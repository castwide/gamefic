module Gamefic

	module ScriptContexts
		#STRING = Context.new("text", [String])
		#INVENTORY = Context.new("my_thing", [[:self, :children]])
		#PROXIMATE = Context.new("thing_in_room", [[:parent, :children]])
		#NEIGHBOR = PROXIMATE
		#NEARBY = PROXIMATE
		#PARENT = Context.new("place", [:parent])
		#PLACE = PARENT
		#ENVIRONMENT = Context.new("thing", [[:self, :children], [:parent, :children]])
		#NEARBY_OR_INVENTORY = ENVIRONMENT
		#ANYWHERE = Context.new("thing_anywhere", [Object])
		#ALL = ANYWHERE	
	end

	class Script
		include ScriptContexts
		def initialize subject
			@subject = subject
			@top = self
		end
		def load filename
			File.open(filename) do |file|
				eval(file.read, binding, filename, 1)
			end
		end
		def method_missing(symbol, *arguments, &block)
			if block != nil
				arguments.push block
			end
			commands = @subject.script_commands
			if commands[symbol]
				commands[symbol].call(arguments)
			else
				super
			end
		end
		private
		def get_binding(script)
			return binding
		end
	end
	
	module Scriptable
		#STRING = Context.new("text", [String])
		#INVENTORY = Context.new("my_thing", [[:self, :children]])
		#PROXIMATE = Context.new("thing_in_room", [[:parent, :children]])
		#NEIGHBOR = PROXIMATE
		#NEARBY = PROXIMATE
		#PARENT = Context.new("place", [:parent])
		#PLACE = PARENT
		#ENVIRONMENT = Context.new("thing", [[:self, :children], [:parent, :children]])
		#NEARBY_OR_INVENTORY = ENVIRONMENT
		#ANYWHERE = Context.new("thing_anywhere", [Object])
		#ALL = ANYWHERE	
		#def script filename
		#	s = Script.new self
		#	s.load filename
		#end
		def load filename
			File.open(filename) do |file|
				eval(file.read, binding, filename, 1)
			end
		end
	end

end
