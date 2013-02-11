class Room < Entity
	def tell(message, except = [])
		(@children.to_ary - except).each { |c|
			c.tell message
		}
	end
	def connect(destination, direction, type = Portal, twoway = true, arguments = nil)
		if destination.kind_of?(Room) == false
			raise "Connection's destination must be a room."
		end
		portal = type.create(
			:parent => self
		)
		if portal.kind_of?(Portal) == false
			raise "Connection type must be a portal."
		end
		portal.name = direction
		portal.destination = destination
		if twoway == true
			wayback = _get_wayback(direction)
			back = type.create(
				:parent => destination
			)
			back.name = wayback
			back.parent = destination
			back.destination = self
		end
		if (arguments != nil)
			arguments.each { |key, value|
				if portal.respond_to?("#{key}=")
					portal.method("#{key}=").call(value)
				end
			}
		end
	end
	
	private
	
		def _get_wayback(direction)
			case direction
				when "north"
					return "south"
				when "south"
					return "north"
				when "west"
					return "east"
				when "east"
					return "west"
				when "northwest"
					return "southeast"
				when "southeast"
					return "northwest"
				when "northeast"
					return "southwest"
				when "southwest"
					return "northeast"
				when "up"
					return "down"
				when "down"
					return "up"
			end
			return nil
		end
end

class Portal < Entity
	def destination
		@destination
	end
	def destination=(value)
		if (value.kind_of?(String) == true)
			room = game.entities[value]
			if room == nil
				raise "Portal destination name #{value} is not valid."
			end
		else
			room = value
		end
		if (room.kind_of?(Room) == false)
			raise "Portal destination must be a room (#{room.class} given)."
		end
		@destination = room
	end
	def reverse
		@reverse
	end
	def reverse_path
		if @destination.kind_of?(Room)
			portals = @destination.children.delete_if {|c| c.kind_of?(Portal) == false}
			portals.each { |po|
				if po.destination == self.parent
					return po
				end
			}
			return nil
		end
		return nil
	end
end

class Door < Portal
	def initialize
		super
		@opened = false
		@keywords = "door"
	end
	def opened?
		@opened
	end
	def opened=(value)
		@opened = value
		if reverse_path != nil
			if reverse_path.opened? != value
				reverse_path.opened = value
			end
		end
	end
	def longname
		if @longname == ""
			return "the door #{name}"
		end
		@longname
	end
end

module CharacterPosition
	NORMAL = 0
	BUSY = 1
	STUCK = 2
end

class Character < Entity
	def initialize
		super
		@position_code = CharacterPosition::NORMAL
		@position_action = ''
	end
	def is_are
		@name.downcase == 'you' ? 'are' : 'is'
	end
	def perform(command)
		parts = Parser.parse(command.strip)
		if parts == nil or parts[0] == nil
			# Tell the actor there was a problem
			self.tell "I don't know what you mean by '#{command.strip}.'"
			return
		end
		command = parts[0]
		target = parts[1]
		tool = parts[2]
		target = Entity.bind(target, self, @parent)
		if target.kind_of?(Array)
			self.tell "'#{parts[1].to_s.cap_first}' might refer to any of the following: #{target.join(", ")}"
			return
		end
		if (target == nil)
			target = parts[1]
		end
		tool = Entity.bind(tool, self, self.parent)
		if tool.kind_of?(Array)
			self.tell "'#{parts[2].to_s.cap_first}' might refer to any of the following: #{tool.join(", ")}"
			return
		end
		if (tool == nil)
			tool = parts[2]
		end
		execute(command, target, tool, parts[1], parts[2])
	end
	def set_position(position_code, position_action = '')
		@position_code = position_code
		@position_action = position_action
	end
	def execute(command, target, tool, target_text = '', tool_text = '')
		if command == nil
			return
		end
		if @position_code != CharacterPosition::NORMAL and Action.is_passive?(command) == false
			case @position_code
				when CharacterPosition::BUSY
					@position_code = CharacterPosition::NORMAL
					self.perform @position_action
				when CharacterPosition::STUCK
					@position_code = CharacterPosition::NORMAL
					self.perform @position_action
					@position_code = CharacterPosition::STUCK
					return
			end
		end
		act = Action.find(command, target, tool, self.parent)
		if act != nil
			if act.key[1] == String
				target = target_text
			end
			if act.key[2] == String
				tool = tool_text
			end
			act.perform(self, target, tool)
			return true
		end
		return false
	end
end

class Player < Character
	def perform(command)
		super command
	end
	def tell(message)
		puts message.terminalize
	end
end

class Item < Entity
	def initialize
		super
		@portable = true
	end
end

class Container < Item
	def initialize
		super
		@opened = false
	end
	def opened?
		@opened
	end
	def opened=(value)
		@opened = value
	end
end

class Scenery < Entity

end

class Location < Entity
	def initialize
		super
		@entrance = nil
		@public = true
	end
	def entrance
		@entrance
	end
	def entrance=(room)
		if (room.parent == nil)
			add room
		elsif room.parent != self
			raise "Entrance to location must be a room inside of it"
		end
		@entrance = room
	end
	def public
		@public
	end
	def rooms
		@room
	end
	def parent=(value)
		raise "Locations cannot have parents"
	end
	def add(room)
		if (room.kind_of?(Room) == false)
			raise "Only rooms can be added to locations"
		end
		room.parent = self
		if @entrance == nil
			@entrance = room
		end
		room
	end
end
