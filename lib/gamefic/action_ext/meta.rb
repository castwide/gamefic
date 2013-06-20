module Gamefic

	Action.new Story.instance, :quit do |actor|
		exit
	end

end
