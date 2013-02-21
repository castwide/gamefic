require "libx/randomcharacters"

# PARTS OF A MURDER CASE
#  Victim
#  Killer
#  Suspects
#  InstantLead: An item that reveals the name and location of a suspect upon examination.


module Gamefic

	class Murder < Episode
		attr_reader :randchar, :victim, :killer, :suspects
		def initialize
			super
			@randchar = RandomCharacters.new
			# Here are the things we need for a mystery
			@victim = Victim.new self
			@killer = Suspect.new self
			@suspects = Array.new
			@suspects.push @killer
			# TODO: Create more suspects
			@suspects.push Suspect.new(self)
			# Add an InstantLead to the crime scene
			suspect = @suspects.random
			containers = victim.zone.flatten.that_are(Container)
			if containers.length == 0
				raise "Nowhere to put it?"
			end
			# TODO: Randomize the type of instant lead (business card, letter, paycheck, etc.)
			lead = InstantLead.new :name => "business card", :longname => "#{suspect.name}'s business card", :description => "A business card listing an office address for #{suspect.name}.", :parent => containers.random, :suspect => suspect
			# TODO: More randomization with suspect leads. Array.shuffle could come in useful here.
			@suspects.each { |suspect|
				lead = InstantLead.new :name => "business card", :longname => "#{suspect.name}'s business card", :description => "A business card listing an office address for #{suspect.name}.", :parent => containers.random, :suspect => suspect
			}
			@victim.zone.parent = self
			action :look, query(:family, InstantLead) do |actor, lead|
				lead.suspect.know
				lead.suspect.locate
				passthru
			end
			action :solve do |actor|
				actor.tell "The killer is #{killer.name}."
			end
			action :search, query(:family, Container) do |actor, container|
				actor.tell "You find: #{container.children.join(', ')}"
			end
			action :take_from, query(:family, Container), subquery(:children, Portable) do |actor, container, item|
				actor.tell "You take #{item.longname} from #{container.longname}."
				item.parent = actor
			end
			instruct "take [item] from [container]", :take_from, "[container] [item]"
			instruct "get [item] from [container]", :take_from, "[container] [item]"
			introduction do |actor|
				actor.tell "You are now investigating the murder of #{victim.name}."
			end
		end
		class CaseSubject
			attr_reader :name, :character, :zone, :story
		end
		class Victim < CaseSubject
			def initialize story
				@story = story
				@name = story.randchar.generate
				@character = Container.new :name => "body", :longname => "#{name.full}'s body", :synonyms => "dead corpse victim"
				# TODO: Randomize zone. Add more rooms.
				@zone = Zone.new
				@cause = nil # TODO: Cause of death. Implement later.
				waypoint = Waypoint.new :parent => zone,
					:name => 'driveway',
					:location => "#{name}'s house"
				living_room = Room.new :parent => zone,
					:name => "living room"
				living_room.connect waypoint, "west"
				# TODO: Randomize containers
				Container.new :name => "wastebasket", :parent => living_room
				@character.parent = living_room
			end
		end
		class Suspect < CaseSubject
			def initialize story
				@story = story
				@name = story.randchar.generate
				@character = Fixture.new :name => name.first, :longname => name.full, :synonyms => "suspect"
				@zone = Zone.new
				waypoint = Waypoint.new :parent => zone,
					:name => 'driveway',
					:location => "#{name}'s house"
				living_room = Room.new :parent => zone,
					:name => "living room"
				living_room.connect waypoint, "west"
				@character.parent = living_room
				# TODO: Randomize containers
				Container.new :name => "wastebasket", :parent => living_room
				@known = false
				@located = false
			end
			def known?
				@known
			end
			def located?
				@located
			end
			def know
				@known = true
			end
			def locate
				@zone.parent = story
				@located = true
			end
		end
		class InstantLead < Item
			attr_accessor :suspect
		end
		class RandomContainers
			def initialize
				@containers[] = [
					'wastebasket', 'cabinet', 'dresser', 'refrigerator', 'nightstand', 'bureau', 'suitcase', 'briefcase', 'bookshelf', 'umbrella stand', 'shoebox'
				]
			end
		end
	end

end
