require "libx/randomcharacters"

# PARTS OF A MURDER CASE
#  Victim
#  Killer
#  Suspects
#  Leads: Things that identify suspects.
#    InstantLead: An item that reveals the name and location of a suspect upon examination.
#    NameLead: An item (e.g., a phone message) that provides a name but requires questioning a suspect to get a location.
#    TwoPartLead: An item (e.g., a photograph) that needs to be shown to a suspect in order to get a name. Then another suspect needs to provide the location.
#  Clues: Things that implicate suspects.
#    Weapon: An item that may have been the cause of death. Analyze to determine if it was the murder weapon.
#    Bloody item: Something with blood on it. Analyze to determine if it is the victim's blood.
#    Alibi: A suspect's whereabouts at the time of the murder. Corroborate with related suspect to determine if it is false.
#    Threat: A letter threatening the victim. Compare with handwriting sample from suspect to determine if the suspect wrote it.
#    Motive: A suspect's declaration of another suspect's reason to kill the victim.
#  Strong clues: weapon, bloody item
#    There should be a maximum of one strong clue that implicates the killer.
#  Weak clues: alibi, threat, motive
#    In the absence of strong evidence against the killer, there should be at least three pieces of weak evidence. Innocent suspects should have two or less.
#  Evidence: Any clue that implicates a suspect.

#  Other Features
#    Suspects can walk around randomly.
#    Suspects can leave zone altogether. Player might be able to force the suspect out of the house. (outstanding arrest warrant)
#    Suspects may or may not permit the player to search their house. The killer is less likely to permit (almost never with a strong clue). In some cases the suspect might follow the player from room to room.
#    Player might be able to force the suspect to submit to a search. (intimidation, charm)
#    Players can learn about suspects from outside sources. Examples:
#      Check DMV records to get an address.
#      Run a police background check to get an address or a known acquaintance.
#      Ask an informant.

module Gamefic

	class Murder < Episode
		attr_reader :randchar, :victim, :killer, :suspects
		def initialize
			super
			declare "scripts/inventory.rb"
			@randchar = RandomCharacters.new
			# Here are the things we need for a mystery
			@victim = Victim.new self
			@victim.zone.parent = self
			@killer = Suspect.new self
			@suspects = Array.new
			@suspects.push @killer
			# TODO: Create more suspects (maybe between 2 and 5 in addition to killer)
			@suspects.push Suspect.new(self)
			add_instant_leads
			# TODO: Other types of leads.
			# TODO: Clues.
			# ...
			# Add the victim's zone to the story
			@victim.zone.parent = self
			action :look, query(:family, InstantLead) do |actor, lead|
				lead.suspect.know
				lead.suspect.locate
				passthru
			end
			# Actions and Instructions
			action :solve do |actor|
				actor.tell "The killer is #{@killer.name}."
			end
			action :search, query(:family, Container) do |actor, container|
				if container.children.length == 0
					actor.tell "You don't find anything."
				else
					actor.tell "You find: #{container.children.join(', ')}"
				end
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
		private
		def add_instant_leads
			lead_sources = @suspects.shuffle
			lead_subjects = @suspects.shuffle
			# TODO: Victim should always have an InstantLead, but they should be optional in suspect's zones (i.e., % chance)
			([@victim] + lead_sources).each { |source|
				subject = lead_subjects.clone.delete_if{ |s| s == source }.shift
				containers = source.zone.flatten.that_are(Container)
				if subject != nil and containers.length > 0
					# TODO: Randomize the type of instant lead (business card, letter, paycheck, etc.)
					lead = InstantLead.new :name => "business card", :longname => "#{subject.name}'s business card", :description => "A business card listing an office address for #{subject.name}.", :parent => containers.random, :suspect => subject
				end
				lead_subjects.delete subject
			}
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
