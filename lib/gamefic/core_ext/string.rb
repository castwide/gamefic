class String
	def capitalize_first
		"#{self[0,1].upcase}#{self[1,self.length]}"
	end
	def cap_first
		self.capitalize_first
	end
	def split_words
		self.gsub(/ +/, ' ').strip.split
	end
end
