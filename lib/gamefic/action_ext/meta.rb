module Gamefic

	Action.new nil, :quit do |actor|
		actor.destroy
	end
	Action.new nil, :commands do |actor|
		actor.tell actor.plot.commandwords.sort.join(", ")
	end

end
