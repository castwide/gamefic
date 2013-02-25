require "libx/randomcharacters"

# victim
# killer
# cause_of_death
# suspects (including killer)
# leads (start with InstantLead)

module Gamefic

	class Investigation
		def initialize(story)
			@story = story
			@randchar = RandomCharacters.new
			@victim = Person.new
			@killer = Person.new
			@suspects = Array.new
			@suspects.push @killer
			@suspects.push Person.new
			@locations = Array.new
			
		end
		def suspects
			@suspects
		end
		class Person
			def initialize
				attr_reader :name
				@name = @randchar.generate
				@known = false
			end
			def known?
				@known
			end
		end
		class Location
			def initialize(name)
				@known = false
			end
			def known?
				@known
			end
		end
	end

end
