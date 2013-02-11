class Action
	@@hash = Hash.new
	def initialize(command, target = nil, tool = nil, location = nil, &func)
		@command = command
		@target = target
		@tool = tool
		@location = location
		@proc = func
		@@hash[[command, target, tool, location]] = self
		user_friendly = command.gsub(/_/, ' ')
		syntax = ''
		num = 1
		if target != nil
			syntax = syntax + " [object#{num}]"
			num = num + 1
		end
		if tool != nil
			syntax = syntax + " [object#{num}]"
		end
		Parser.translate user_friendly + syntax, command + syntax, false
	end
	def key
		return [@command, @target, @tool, @location]
	end
	def perform(actor, target, tool)
		@proc.call(actor, target, tool)
	end
	def Action.find(command, target, tool, location)
		axis_x = Action.explode(target)
		axis_y = Action.explode(tool)
		axis_z = Action.explode(location)
		axis_x.each { |x|
			axis_y.each { |y|
				axis_z.each { |z|
					act = @@hash[[command, x, y, z]]
					if act != nil
						return act
					end
				}
			}
		}
		return nil
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
