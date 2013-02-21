class RandomCharacters
	def initialize
		@first_names_male = [
			'Joe', 'Mike', 'John', 'Frank', 'Edward', 'Jerry', 'Ben', 'Robert', 'Bobby', 'Jack', 'Arnold', 'Ted', 'Bill', 'Steve', 'Peter', 'Brett', 'Todd', 'Nick', 'Scott', 'Chris', 'Harry', 'Jason', 'Dan', 'Rudy'
		]
		@first_names_female = [
			'Karen', 'Sally', 'Jennifer', 'Alice', 'Ellen', 'Mary', 'Ann', 'Taylor', 'Erica', 'Jessica', 'Ginger', 'Lois', 'Natalie', 'Ingrid', 'Wanda', 'Nikki', 'Brittany', 'Jane', 'Liz'
		]
		@last_names = [
			'Smith', 'Jones', 'Johnson', 'Wendell', 'Carpenter', 'Black', 'White', 'Clark', 'Reynolds', 'Samuels', 'Baldwin', 'Tyler', 'Simpson', 'Broadus', 'Hammond', 'Sanchez', 'Townsend', 'McBain', 'Griffin', 'King', 'Turner',
			'Foley', 'Riggs', 'Murtaugh', 'Callahan', 'Woods', 'Borden'
		]
	end
	def gender
		rand < 0.5 ? :male : :female
	end
	def first_name(gender = nil)
		case gender
			when :male
				first_names = @first_names_male
			when :female
				first_names = @first_names_female
			else
				first_names = @first_names_male + @first_names_female
		end
		first_names.slice!(rand(first_names.length))
	
	end
	def last_name
		@last_names.slice!(rand(@last_names.length))
	end
	def full_name(gender = nil)
		"#{self.first_name(gender)} #{self.last_name}"	
	end
	def generate(family = nil, gender = nil)
		first = first_name(gender)
		last = family || last_name
		Name.new(first, last, gender)
	end
	class Name
		attr_accessor :first, :last, :gender
		def initialize(first, last, gender)
			@first = first
			@last = last
			@gender = gender
		end
		def full
			"#{@first} #{@last}"
		end
		def to_s
			full
		end
	end
end
