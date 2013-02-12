class String
	def escape_single_quotes
		self.gsub(/[']/, '\\\\\'')
	end
	def symbolize
		self.gsub(/[^a-z0-9]/i, '_').gsub(/_+/, '_')
	end
end

Action.new("list_rooms") { |actor|
	Entity.array.that_are(Room).each { |room|
		actor.tell room.longname
	}
}
Action.new("set_room", Context::STRING) { |actor, data|
	words = data.split_words
	key = words.shift
	if actor.parent.respond_to?("#{key}=")
		actor.parent.method("#{key}=").call(words.join(' '))
		actor.tell "#{key.cap_first} updated."
	else
		actor.tell "#{key.cap_first} is not a valid property for #{actor.parent.longname}."
	end
}
Action.new("connect_room", Context::ANYWHERE.reduce(Room), Context::STRING) { |actor, room, data|
	actor.tell "Connected #{room.name} #{data}."
	actor.parent.connect(room, data)
}
Action.new("disconnect", Context::PARENT.reduce(Portal)) { |actor, portal|
	reverse = Portal.reverse(portal.name)
	puts "Reverse: #{reverse}"
	dest = portal.destination
	dir = portal.name
	other = portal.destination.children.that_are(Portal).matching(reverse)[0]
	portal.destroy
	if other != nil
		other.destroy
	end
	actor.tell "Disconnected from #{dest.longname} #{dir}"
}
Action.new("destroy", Context::ENVIRONMENT) { |actor, object|
	object.destroy
	actor.tell "#{object.longname.cap_first} destroyed."
}
Action.new("create", Context::STRING) { |actor, data|
	words = data.split_words
	name = words.shift
	type = nil
	ObjectSpace.each_object(Class) { |o|
		if name.downcase == o.to_s.downcase
			type = o
			break
		end
	}
	if type != nil
		entity = type.new
		if entity.kind_of?(Entity) == false
			actor.tell "#{name.cap_first} is not an Entity."
		else
			entity.name = words.join(' ')
			if entity.kind_of?(Room) == false
				entity.parent = actor.parent
			end
			actor.tell "You created #{entity.name}."
		end
	else
		actor.tell "#{name.cap_first} is not a class."
	end
}
Action.new("save", Context::STRING) { |actor, filename|
	used_symbols = Array.new
	entities = Entity.array.delete_if{ |e| e.kind_of?(Player) }
	file = File.open(filename, "w")
	num = 1
	parents = ''
	portals = ''
	entities.each { |entity|
		file.write "#{entity.identifier.downcase.symbolize} = #{entity.class}.create(\n"
		file.write "\t:name => '#{entity.name.escape_single_quotes}',\n"
		file.write "\t:longname => '#{entity.longname.escape_single_quotes}',\n"
		file.write "\t:description => '#{entity.description.escape_single_quotes}',\n"
		file.write "\t:synonyms => '#{entity.synonyms.escape_single_quotes}'\n"
		file.write ")\n\n"
		if entity.parent != nil
			parents = parents + "#{entity.identifier.downcase.symbolize}.parent = #{entity.parent.identifier.downcase.symbolize}\n"
		end
		if entity.kind_of?(Portal)
			portals = portals + "#{entity.identifier.downcase.symbolize}.destination = #{entity.destination.identifier.downcase.symbolize}\n"
		end
	}
	file.write parents
	file.write portals
	file.close
}
Action.new("load", Context::STRING) { |actor, filename|
	actor.parent = nil
	Entity.array.delete_if{ |e| e == actor }.each { |e| e.destroy }
	@@game.load filename
	actor.parent = Entity.array.that_are(Room)[0]
}
Action.new("set", Context::ENVIRONMENT, Context::STRING) { |actor, entity, data|
	words = data.split_words
	key = words.shift
	entity.method("#{key}=").call(words.join(' '))
	actor.tell "#{key} updated."
}

Parser.translate("set room [data]", "set_room [data]")
Parser.translate("connect [destination] [direction]", "connect_room [destination] [direction]")
Parser.translate("set [entity] [property] to [value]", "set [entity] [property] [value]")
