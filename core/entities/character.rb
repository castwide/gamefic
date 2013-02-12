class Character < Entity
	def perform(command)
		Delegate.dispatch(self, command)
	end
end

class Context
	NEIGHBOR = Context.new("person", [[:parent, :children], Character])
end
