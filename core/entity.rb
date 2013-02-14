module Gamefic

	class EntityArray < Array
		def that_are(cls)
			if cls.kind_of?(Entity)
				if self.include?(cls)
					return EntityArray.new.push(cls)
				else
					return EntityArray.new
				end
			else
				return self.clone.delete_if {|entity| entity.kind_of?(cls) == false}
			end
		end
		def matching(description)
			result = self.class.new
			#if self.include?(Entity[description])
			#	result.push Entity[description]
			#	return result
			#end
			mostMatches = 0
			words = Keywords.from description
			if words.length == 0
				return self.clone
			end
			self.each {|entity|
				matches = words.found_in entity.keywords
				if matches > 0 and matches - mostMatches >= 0
					if matches - mostMatches > 0.5 and result.length > 0
						result = self.class.new
					end
					mostMatches = matches
					result.push entity
				end
			}
			return result
		end
	end
	
	class Entity
		attr_reader :name, :longname, :parent
		def initialize(story = nil)
			@story = story
			@name = ''
			@longname = ''
			@description = ''
			@synonyms = ''
			@children = EntityArray.new
			@parent = nil
			@identifier = self.object_id
		end
		def story
			@story != nil ? @story : Theater.instance
		end
		def keywords
			Keywords.from "#{name} #{longname} #{synonyms}"
		end
		def name=(value)
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
		def destroy
			children.each { |c|
				c.parent = nil
			}
			if @parent != nil
				@parent.delete_child(self)
				@parent = nil
			end
			@@hash.delete identifier
		end
		def children
			@children.clone
		end
		def parent=(entity)
			if entity == self
				raise "Entity cannot be its own parent"
			end
			if @parent != nil
				@parent.delete_child(self)
			end
			@parent = entity
			if @parent != nil
				if (@parent.kind_of?(Entity) == false)
					raise "Entity's parent must be another Entity (#{@parent.class} given)"
				end
				@parent.push_child(self)
			end
			if @story == nil and parent.story != nil
				@story = parent.story
				@story.track self
			end
		end
		def tell(message)
			#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
			#TODO: On second thought, it might be interesting to see logs from an npc point of view.
		end
		def to_s
			@name
		end
		protected
		def delete_child(c)
			@children.delete c
		end
		def push_child(c)
			@children.push c
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
