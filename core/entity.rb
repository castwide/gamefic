require "core/node.rb"

module Gamefic
	
	class Entity
		include Branch
		attr_reader :name, :longname, :parent
		def initialize
			@name = ''
			@longname = ''
			@description = ''
			@synonyms = ''
			@children = Array.new
			@parent = nil
			@identifier = self.object_id
		end
		def keywords
			Keywords.new "#{name} #{longname} #{synonyms}"
		end
		def name=(value)
			puts "Setting name to #{value}"
			@name = value
		end
		def longname
			@longname.to_s != '' ? @longname : name
		end
		def longname=(value)
			@longname = value
		end
		def description
			@description.to_s != '' ? @description : "Nothing special."
		end
		def description=(value)
			@description = value
		end
		def synonyms
			@synonyms
		end
		def synonyms=(words)
			@synonyms = words
		end
		def identifier
			@identifier
		end
		#def destroy
		#	children.each { |c|
		#		c.parent = nil
		#	}
		#	if @parent != nil
		#		@parent.delete_child(self)
		#		@parent = nil
		#	end
		#	@@hash.delete identifier
		#end
		def tell(message)
			#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
			#TODO: On second thought, it might be interesting to see logs from an npc point of view.
		end
		def to_s
			@name
		end
		def self.create(arguments)
			entity = self.new
			arguments.each { |key, value|
				entity.method("#{key}=").call(value)
			}
			return entity
		end
	end

end
