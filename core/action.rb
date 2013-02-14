# Map commands to methods and contexts.

module Gamefic

	class Action
		attr_accessor :creation_order
		def initialize(command, contexts, proc)
			if (contexts.length + 1 != proc.arity) and (contexts.length == 0 and proc.arity != -1)
				raise "Number of contexts is not compatible with proc arguments."
			end
			@command = command
			@contexts = contexts
			@proc = proc
			#@creation_order = @@creation_order
			user_friendly = command.to_s.gsub(/_/, ' ')
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
		end
		def command
			@command
		end
		def specificity
			spec = @contexts.length
			@contexts.each { |c|
				spec = spec + c.specificity
			}
			return spec
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
		def create(command, *contexts, &block)
			puts "Here's contexts: #{contexts.length}"
			Action.new(command, contexts, block)
		end
		private
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
	end

end
