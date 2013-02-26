action :say, query(:string) do |actor, message|
	actor.parent.tell "#{actor.longname.cap_first} says, \"#{message}\""
end
