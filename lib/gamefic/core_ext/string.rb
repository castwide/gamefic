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
	def terminalize
		output = ''
		lines = self.split("\n")
		lines.each { |line|
			if line.size > 79
				while (line.size > 79)
					offset = line.rindex(/[\s\W]/, 79)
					if (offset == 0 or offset == nil)
						output = output + line + "\n"
						line = ''
					else
						output = output + line[0,offset + 1] + "\n"
						line = line[offset + 1, line.size - offset]
					end
				end
				output = output + line + "\n"
			else
				output = output + line + "\n"
			end
		}
		return output.strip
	end
	def split_words
		self.gsub(/ +/, ' ').strip.split
	end
end
