# A class to manage commands and the contexts in which they operate.

class Action
	@@hash = Hash.new
	def initialize(command, *contexts, &proc)
		if (contexts.length + 1 != proc.arity) and (contexts.length == 0 and proc.arity != -1)
			raise "Number of contexts is not compatible with proc arguments."
		end
		@command = command
		@contexts = contexts
		@proc = proc
		user_friendly = command.gsub(/_/, ' ')
		syntax = ''
		used_names = Array.new
		contexts.each { |c|
			num = 1
			new_name = "[#{c.description}]"
			while used_names.include? new_name
				num = num + 1
				new_name = "[#{c.description}#{num}]"
			end
			syntax = syntax + " #{new_name}"
		}
		conversion = Parser.translate user_friendly + syntax, command + syntax, false
		@key = conversion.signature
		@@hash[@key] = self
	end
	def key
		@key
	end
	def contexts
		@contexts
	end
	def proc
		@proc
	end
	#def perform(actor)
	#	@proc.call(actor, target, tool)
	#end
	#def self.find(command, target, tool, location)
		
		#axis_x = Action.explode(target)
		#axis_y = Action.explode(tool)
		#axis_z = Action.explode(location)
		#axis_x.each { |x|
		#	axis_y.each { |y|
		#		axis_z.each { |z|
		#			act = @@hash[[command, x, y, z]]
		#			if act != nil
		#				return act
		#			end
		#		}
		#	}
		#}
		#return nil
	#end
	def self.[](key)
		@@hash[key]
	end
	#######################################################################
	private
	#######################################################################
	def Action.explode(entity)
		arr = Array.new
		arr.push entity
		cls = entity.class
		while cls != Object
			arr.push cls
			cls = cls.superclass
		end
		arr.push String
		arr.push nil
	end
end
