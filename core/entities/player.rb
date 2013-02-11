class Player < Character
	def perform(command)
		super command
	end
	def tell(message)
		puts message.terminalize
	end
end
