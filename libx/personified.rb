require "lib/array"

module Gamefic

	module Personified
		attr_accessor :gender, :proper_name, :physique, :age
		@@male_names = []
		@@female_names = []
		@@last_names = []
		@@male_physiques = []
		@@female_physiques = []
		@@ages = []
		def personify
			if @gender == nil
				@gender = (rand(2) == 1 ? :male : :female)
			end
			@proper_name = ProperName.new(Personified.get_first_name(gender), Personified.get_last_name)
			@physique = Personified.get_physique(gender)
			@age = Personified.get_age
		end
		def gender_noun
			case @gender
				when :male
					"man"
				when :female
					"woman"
				else
					"person"
			end
		end
		def pronoun
			case @gender
				when :male
					"he"
				when :female
					"she"
				else
					"it"
			end
		end
		def possessive
			case @gender
				when :male
					"his"
				when :female
					"her"
				else
					"its"
			end
		end
		def objective
			case @gender
				when :male
					"him"
				when :female
					"her"
				else
					"it"
			end
		end
		def physical_description
			"#{physique} #{gender_noun} in #{possessive} #{age}"
		end
		def self.read(filename, array)
			File.open(filename, "r") do |file|
				while (line = file.gets)
					if line != ''
						array.push line.strip
					end
				end
			end
		end
		def self.get_first_name(gender = nil)
			if (gender == nil)
				# Temporarily assign a gender just to pick an array
				gender = (rand(2) == 1 ? :male : female)
			end
			case gender
				when :male
					if @@male_names.length == 0
						self.read("libx/male_names.txt", @@male_names)
					end
					@@male_names.shuffle!
					return @@male_names.shift
				else
					if @@female_names.length == 0
						self.read("libx/female_names.txt", @@female_names)				
					end
					@@female_names.shuffle!
					return @@female_names.shift
			end
		end
		def self.get_last_name
			if @@last_names.length == 0
				self.read("libx/last_names.txt", @@last_names)
			end
			@@last_names.shuffle!
			return @@last_names.shift
		end
		def self.get_physique(gender = nil)
			if (gender == nil)
				# Temporarily assign a gender just to pick an array
				gender = (rand(2) == 1 ? :male : :female)
			end
			case gender
				when :male
					if @@male_physiques.length == 0
						self.read("libx/male_physiques.txt", @@male_physiques)
					end
					@@male_physiques.shuffle!
					return @@male_physiques.shift
				else
					if @@female_physiques.length == 0
						self.read("libx/female_physiques.txt", @@female_physiques)
					end
					@@female_physiques.shuffle!
					return @@female_physiques.shift
			end
		end
		def self.get_age
			if @@ages.length == 0
				self.read("libx/ages.txt", @@ages)
			end
			@@ages.shuffle!
			return @@ages.shift	
		end
		class ProperName
			attr_reader :first, :last
			def initialize(first, last)
				@first = first
				@last = last
			end
			def full
				"#{first} #{last}"
			end
			def to_s
				full
			end
		end
	end

end
