class Array
	def that_are(cls)
		if (cls.kind_of?(Class) or cls.kind_of?(Module))
			return self.clone.delete_if { |i| i.kind_of?(cls) == false }
    elsif cls.kind_of?(Symbol)
      return self.clone.delete_if { |i| i.option_selected?(cls) == false }
		else
			if self.include?(cls)
				return [cls]
			end
			return Array.new
		end
	end
	def that_are_not(cls)
		if (cls.kind_of?(Class) or cls.kind_of?(Module))
			return self.clone.delete_if { |i| i.kind_of?(cls) == true }
    elsif cls.kind_of?(Symbol)
      return self.clone.delete_if { |i| i.option_selected?(cls) == true }
		else
			return self.clone - [cls]
		end
	end
	def random
		return self[rand(self.length)]
	end
  def pop_random
    delete_at(rand(self.length))
  end
	def shuffle
		self.sort { |a, b|
			rand(3) <=> rand(3)
		}
	end
	def shuffle!
		self.sort! { |a, b|
			rand(3) <=> rand(3)
		}
	end
	def join_and(sep = ', ', andSep = ' and ', serial = true)
		if self.length < 3
			self.join(andSep)
		else
			start = self - [self.last]
			start.join(sep) + "#{serial ? sep.strip : ''}#{andSep}#{self.last}"
		end
	end
end
