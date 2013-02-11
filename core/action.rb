# Map commands to methods and contexts.

class Action
	@@hash = Hash.new
	@@creation_order = 0
	def initialize(command, *contexts, &proc)
		if (contexts.length + 1 != proc.arity) and (contexts.length == 0 and proc.arity != -1)
			raise "Number of contexts is not compatible with proc arguments."
		end
		@command = command
		@contexts = contexts
		@proc = proc
		@creation_order = @@creation_order
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
			used_names.push new_name
			syntax = syntax + " #{new_name}"
		}
		#@key = generate_key
		#@@hash[@key] = self
		if @@hash[command] == nil
			@@hash[command] = Array.new
		end
		@@hash[command].push self
		@@hash[command].sort { |a,b|
			if b.specificity != a.specificity
				b.specificity <=> a.specificity
			else
				b.creation_order <=> a.creation_order
			end
		}
		@@creation_order = @@creation_order + 1
		conversion = Parser.translate user_friendly + syntax, command + syntax
	end
	def specificity
		count_context_arguments(contexts)
	end
	#def self.find(syntax)
	#	key = Action.generate_key(syntax)
	#	@@hash[key]
	#end
	def self.actions_for(command)
		@@hash[command]
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
	#######################################################################
	private
	#######################################################################
	def self.explode(entity)
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
	#def self.generate_key(syntax)
	#	words = syntax.split_words
	#	return "#{words[0]}:#{(words.length - 1)}"	
	#end
	def count_context_arguments(context)
		if (context.kind_of?(Array))
			arg = context.length
			context.each { |c|
				arg = arg + count_context_arguments(c)
			}
			arg
		else
			1
		end
	end
	protected
	def creation_order
		@creation_order
	end
end
