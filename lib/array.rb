class Array
	def that_are(cls)
		return self.clone.delete_if { |i| i.kind_of?(cls) == false }
	end
	def that_are_not(cls)
		return self.clone.delete_if { |i| i.kind_of?(cls) == true }
	end
	def random
		return self[rand(self.length)]
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
end

x = ['a','b','c','d','e']
puts "#{x}"
x.shuffle!
puts "#{x}"