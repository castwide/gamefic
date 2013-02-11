module FurniturePosition
	EXTEND_ENTITIES = [Character]
	NORMAL = 0
	SITTING = 1
	LYING = 2
	attr :furniture_position
	attr :furniture_entity
	def furniture_position
		if @furniture_position == nil
			@furniture_position = NORMAL
		end
		@furniture_position
	end
	def furniture_entity
		@furniture_entity
	end
	def set_furniture_position(pos, furn = nil)
		if pos == nil
			pos = NORMAL
		end
		@furniture_position = pos
		if pos == NORMAL
			@furniture_entity = nil
		else
			set_position CharacterPosition::BUSY, 'stand up'
			@furniture_entity = furn
		end
	end
	def name
		if self.furniture_position != NORMAL
			return "#{super} (#{self.furniture_position_short_description})"
		end
		super
	end
	def description
		if self.furniture_position == NORMAL
			return super
		end
		return "#{super}\n#{self.longname.cap_first} #{self.is_are} #{self.furniture_position_long_description}."
	end
	def furniture_position_short_description
		case self.furniture_position
			when SITTING
				return "sitting on #{@furniture_entity.name}"
			when LYING
				return "lying on #{furniture_entity.name}"
		end
		return ""
	end
	def furniture_position_long_description
		case self.furniture_position
			when SITTING
				return "sitting on #{@furniture_entity.longname}"
			when LYING
				return "lying on #{furniture_entity.longname}"
		end
		return ""
	end
end

class Furniture < Item
	def initialize
		super
		@portable = false
	end
end

class Seat < Furniture

end

class Bed < Seat

end

Action.new("sit", Seat, nil, nil) { |actor, target, tool|
	if actor.furniture_position == FurniturePosition::NORMAL
		using = actor.parent.children.to_ary.clone.delete_if { |c|
			c.kind_of?(Character) == false or c.furniture_entity != target
		}
		if using.length < 1
			actor.set_furniture_position(FurniturePosition::SITTING, target)
			actor.tell "You sit on #{target.longname}."
		elsif using.length == 1
			actor.tell "#{using[0].name.cap_first} is already sitting there."
		else
			actor.tell "There's not enough room for you to sit."
		end
	else
		case actor.furniture_position
			when FurniturePosition::SITTING
				actor.tell "You're already sitting."
			when FurniturePosition::LYING
				actor.tell "You're already lying down."
			else
				raise "Unknown position."
		end
	end
}

Action.new("sit", Entity, nil, nil) { |actor, target, tool|
	actor.tell "You cannot sit on #{target.longname}."
}

Action.new("stand", nil, nil) { |actor, target, tool|
	if actor.furniture_position == FurniturePosition::NORMAL
		actor.tell "You're already standing."
	else
		actor.set_furniture_position(FurniturePosition::NORMAL, nil)
		actor.tell "You stand up."
	end
}

Action.new("put", Entity, Furniture, nil) { |actor, target, tool|
	if target.parent != actor
		game.execute(actor, "get", target, nil)
	end
	if target.parent == actor
		actor.tell "You put #{target.longname} on #{tool.longname}."
		target.move_to(tool.parent)
		target.set_furniture_position(FurniturePosition::SITTING, tool)
	end
}

Action.new("lie", nil, nil, nil) { |actor, target, tool|
	actor.tell "No time to nap. You have work to do."
}

Parser.add("sit {object}", "sit {object}")
Parser.add("sit on {object}", "sit {object}")
Parser.add("stand", "stand")
Parser.add("stand up", "stand")
Parser.add("set {object} on {furniture}", "put {object} {furniture}")
Parser.add("put {object} on {furniture}", "put {object} {furniture}")
Parser.add("drop {object} on {furniture}", "put {object} {furniture}")
Parser.add("lie down {place}", "lie {place}")
Parser.add("lie down on {place}", "lie {place}")
Parser.add("lie on {place}", "lie {place}")
Parser.add("lie down", "lie")

Action.set_passive "sit"
Action.set_passive "stand"
Action.set_passive "lie"
