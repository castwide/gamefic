class Entity
	@@hash = Hash.new
	class EntityArray < Array
		def that_are(cls)
			self.clone.delete_if {|entity| entity.kind_of?(cls) == false}
		end
		def matching(description)
			result = self.class.new
			if Entity[description] != nil and self.include?(Entity[description])
				result.push Entity[description]
				return result
			end
			mostMatches = 0
			words = Keywords.from description
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
	def self.empty
		EntityArray.new
	end
	def self.array
		EntityArray.new.concat(@@hash.values)
	end
	def self.[](identity)
		@@hash[identity]
	end
end

class Entity
	attr_reader :name, :description, :parent
	def initialize
		@children = EntityArray.new
		@parent = nil
		@identifier = self.object_id
		@@hash[@identifier] = self
	end
	def keywords
		Keywords.from "#{@name} #{@longname} #{@synonyms}"
	end
	def name=(value)
		@name = value
		@@hash.delete @identifier
		if @@hash.has_key?(@name.downcase)
			@identifier = self.object_id
		else
			@identifier = @name.downcase
		end
		@@hash[@identifier] = self
	end
	def longname
		@longname ? @longname : @name
	end
	def longname=(value)
		@longname = value
	end
	def description=(value)
		@description = value
	end
	def synonyms=(words)
		@synonyms = words
	end
	def children
		@children.clone
	end
	def parent=(entity)
		if @parent != nil
			@parent.child_array.delete(self)
		end
		if entity == self
			raise "Entity cannot be its own parent"
		end
		@parent = entity
		if @parent != nil
			if (@parent.kind_of?(Entity) == false)
				raise "Entity's parent must be another Entity (#{@parent.class} given)"
			end
			@parent.child_array.push(self)
		end
	end
	def tell(message)
		#TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
	end
	def to_s
		@name
	end
	protected
	def child_array
		@children
	end
	def self.create(arguments)
		entity = self.new
		arguments.each { |key, value|
			entity.method("#{key}=").call(value)
		}
		return entity
	end
end
