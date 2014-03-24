class String
	def capitalize_first
		"#{self[0,1].upcase}#{self[1,self.length]}"
	end
	def cap_first
		self.capitalize_first
	end
  def specify
    if self[0,2] == 'a ' or self[0,3] == 'an '
      return "the #{self.split(' ')[1..-1].join(' ')}"
    end
    if self[0,2] == 'A ' or self[0,3] == 'An '
      return "The #{self.split(' ')[1..-1].join(' ')}"
    end
    return self
  end
	def split_words
		self.gsub(/ +/, ' ').strip.split
	end
end
