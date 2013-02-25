#require "libx/randomcharacters"
require "libx/personified.rb"

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
			# Initialize @suspects first so the children method won't fail
			@suspects = Array.new
			super
			declare "scripts/inventory.rb"
			declare "scripts/container.rb"

			# Here are the things we need for a mystery
			@victim = Victim.new self
			@victim.zone.parent = self
			@killer = Suspect.new self
			@suspects.push @killer
			@suspects.push Suspect.new(self)
			@suspects.push Suspect.new(self)
			@suspects.push Suspect.new(self)
			@suspects.shuffle!
			@clues = Array.new
			add_instant_leads
			# TODO: Other types of leads.
			# ...
			add_strong_clues
			# TODO: Other types of clues.
			# ...
			add_alibis
			# Add the victim's zone to the story
			@victim.zone.parent = self
			action :look, query(:family, InstantLead) do |actor, lead|
				lead.suspect.know
				lead.suspect.locate
				passthru
			end
			# Actions and Instructions
			action :solve do |actor|
				actor.tell "The killer is #{@killer.proper_name}."
				actor.tell "The first suspect is #{@suspects[0].proper_name}."
			end
			action "^review".to_sym, query(:root, Suspect) do |actor, suspect|
				actor.tell "+--"
				actor.inject "review #{suspect.uid}"
				actor.tell "---"
			end
			action :review, query(:root, Suspect) do |actor, suspect|
				if suspect.known?
					actor.tell "#{suspect.name}"
					#clues = @clues.clone
					#clues.delete_if { |c| c.suspect != suspect }
					clues = actor.children.that_are(Clue)
					clues = clues + @clues.clone.delete_if { |c| c.analyzed? == false }
					clues.uniq!
					if clues.length == 0
						actor.tell "You don't have any clues for this suspect yet."
					else
						actor.tell "Clues:"
						clues.each { |c|
							actor.tell "#{c.longname}: #{c.analyzed? ? (suspect == killer ? 'CONFIRMED' : 'negative') : 'analysis pending'}"
						}
					end
					if suspect.alibi_status == Suspect::ALIBI_UNKNOWN
						actor.tell "Alibi: unknown"
					else
						actor.tell "Alibi: #{suspect.alibi.longname} (#{suspect.alibi_status})"
					end
				else
					passthru
				end
			end
			action "^review_case".to_sym do |actor|
				actor.tell "+--"
				actor.inject "review case"
				@suspects.each { |s|
					if s.known?
						actor.tell "`^review #{s.uid}` (review #{s.longname})"
					end
				}
				actor.tell "---"
			end
			action :review, query(:string) do |actor, string|
				# TODO: This is a terrible wart. 
				if string == "case"
					passthru
				else
					actor.tell "You don't know a suspect named #{string}."
				end
			end
			action :review_case do |actor|
				actor.tell "Victim: #{@victim.proper_name}"
				actor.tell "Cause of death: gunshot"
				known = Array.new
				@suspects.each { |suspect|
					if suspect.known?
						known.push "#{suspect.proper_name} #{suspect.located? ? '(located)' : '(address unkown)'}"
					end
				}
				actor.tell "Known suspects: #{known.length > 0 ? known.join(', ') : 'none'}"
			end
			instruct "review case", :review_case, ""
			action :accuse, query(:siblings, Character) do |actor, suspect|
				clues = actor.children.that_are(Clue)
				clues = clues + @clues.clone.delete_if { |c| c.analyzed? == false }
				clues.uniq!
				clues.delete_if{ |c| c.suspect != suspect }
				# TODO: Might require 3 pieces of evidence.
				evidence = clues.length
				if suspect.alibi_status == Suspect::ALIBI_FAKE
					evidence += 1
				end
				if evidence < 2
					actor.tell "You don't have enough evidence to accuse #{suspect}."
				else
					if suspect == @killer
						conclude :solved, actor
					else
						conclude :unsolved, actor
					end
				end
			end
			action :ask_alibi, query(:siblings, Suspect) do |actor, suspect|
				actor.tell "#{suspect.longname.cap_first} claims to have been with #{suspect.alibi.proper_name} at the time of the murder."
				suspect.alibi_requested
				suspect.alibi.know
			end
			action :ask_alibi, query(:siblings, Character) do |actor, suspect|
				actor.tell "#{suspect.longname.cap_first} is not a suspect in anything."
			end
			action :ask, query(:siblings, Suspect), query(:root, Suspect) do |actor, suspect, subject|
				if suspect != subject
					actor.tell "#{suspect.name} happily tells you where to find #{subject.proper_name}."
					subject.locate
				end
			end
			action :ask, query(:siblings, Suspect), query(:root, @victim) do |actor, suspect, victim|
				# TODO: We can do better.
				lead = @suspects.random
				actor.tell "#{suspect.proper_name} gives you a lead: #{lead.proper_name}."
				lead.know
				lead.locate
			end
			instruct "ask [person] about alibi", :ask_alibi, "[person]"
			instruct "ask [person] for alibi", :ask_alibi, "[person]"
			instruct "ask [suspect] about [other]", :ask, "[suspect] [other]"
			action :resign do |actor|
				conclude :resigned, actor
			end
			action "^look".to_sym, query(:siblings, Suspect) do |actor, suspect|
				actor.tell "+--"
				actor.tell "# #{suspect.proper_name}"
				actor.tell "#{suspect.description}"
				actor.tell "`review #{suspect.uid}` (Review notes about suspect)"
				if suspect.alibi_status == Suspect::ALIBI_UNKNOWN
					actor.tell "`ask #{suspect.uid} for alibi` (Ask for suspect's alibi)"
				end
				actor.tell "`ask #{suspect.uid} about #{@victim.uid}` (Ask about the victim)"
				@suspects.that_are_not(suspect).each { |other|
					if other.known?
						actor.tell "`ask #{suspect.uid} about #{other.uid}` (Ask about #{other.longname})"
					end
				}
				actor.tell "`accuse #{suspect.uid}` (Accuse the suspect)"
				actor.tell "---"
			end
			action "^resign".to_sym do |actor|
				actor.tell "+--"
				actor.inject "resign"
				actor.tell "---"
			end
			introduction do |actor|
				actor.tell "You've been assigned to investigate the murder of #{victim.proper_name}. Get started by visiting the crime scene."
			end
			conclusion :solved do |actor|
				actor.tell "You solved the case!"
			end
			conclusion :unsolved do |actor|
				actor.tell "You accused the wrong suspect."
			end
			conclusion :resigned do |actor|
				actor.tell "You resigned from the case."
			end
		end
		def children
			(super + @suspects)
		end
		private
		def add_instant_leads
			lead_sources = @suspects.shuffle
			lead_subjects = @suspects.shuffle
			# TODO: Victim should always have an InstantLead, but they should be optional in suspect's zones (i.e., % chance)
			options = [
				{ :name => 'business card', :longname => 'a business card', :description => 'A business card listing an office address for ' },
				{ :name => 'scrap of paper', :longname => 'a scrap of paper', :description => 'The scrap lists an address for ' },
				{ :name => 'envelope', :longname => 'an envelope', :description => 'The return address belongs to ' },
				{ :name => 'contract', :longname => 'a contract', :description => 'A contract signed by '},
				{ :name => 'postcard', :longname => 'a postcard', :synonyms => 'card', :description => 'A postcard from '}
			]
			options.shuffle!
			([@victim] + lead_sources).each { |source|
				option = options.shift
				subject = lead_subjects.clone.delete_if{ |s| s == source }.shift
				containers = source.zone.flatten.that_are(Container)
				if subject != nil and containers.length > 0
					# TODO: Randomize the type of instant lead (business card, letter, paycheck, etc.)
					lead = InstantLead.new :name => option[:name], :longname => option[:longname], :description => "#{option[:description]}#{subject.proper_name}.", :synonyms => option[:synonyms], :parent => containers.random, :suspect => subject
				end
				lead_subjects.delete subject
			}
		end
		def add_strong_clues
			# TODO: Change the weapon based on the cause of death
			# TODO: Also, the murder weapon is not available in all stories
			handgun_names = ['semi-automatic pistol', 'revolver', 'magnum', 'hunting rifle', 'shotgun'];
			handgun_names.shuffle!
			containers = @killer.zone.flatten.that_are(Container)
			h = handgun_names.pop
			weapon = Weapon.new :name => "#{h}", :longname => "a #{h}", :description => "A gun belonging to #{@killer.proper_name}.", :synonyms => "gun", :parent => containers.random, :story => self, :suspect => @killer
			@clues.push weapon
			suspect = @suspects.that_are_not(@killer).random
			containers = suspect.zone.flatten.that_are(Container)
			h = handgun_names.pop
			weapon = Weapon.new :name => "#{h}", :longname => "a #{h}", :description => "A gun belonging to #{suspect.proper_name}.", :synonyms => "gun", :parent => containers.random, :story => self, :suspect => suspect
			@clues.push weapon
		end
		def add_alibis
			suspects = @suspects.that_are_not(@killer)
			suspects.shuffle!
			fake = suspects.shift
			@killer.alibi = suspects.random
			fake.alibi = suspects.random
			suspects[0].alibi = suspects[1]
			suspects[1].alibi = suspects[0]
		end
		class Victim < Container
			attr_reader :zone
			include Personified
			def initialize story
				@story = story
				super()
			end
			def post_initialize
				super
				personify
				@name = "dead body"
				@longname = "#{proper_name.full}'s body"
				@synonyms = "dead victim corpse"
				# TODO: Randomize zone. Add more rooms.
				@zone = Zone.new
				@cause = nil # TODO: Cause of death. Implement later.
				waypoint = Waypoint.new :parent => zone,
					:name => 'driveway',
					:location => "#{proper_name}'s house"
				living_room = Room.new :parent => zone,
					:name => "living room"
				living_room.connect waypoint, "west"
				# TODO: Randomize containers
				Container.new :name => "wastebasket", :synonyms => "trash can basket", :parent => living_room, :image => 'wastebasket.png'
				self.parent = living_room
			end
			def default_image
				"body-outline.png"
			end
		end
		class Suspect < Character
			ALIBI_UNKNOWN = 'unknown'
			ALIBI_UNCONFIRMED = 'unconfirmed'
			ALIBI_REAL = 'real'
			ALIBI_FAKE = 'fake'
			attr_reader :zone
			attr_accessor :alibi
			include Personified
			def initialize story
				@story = story
				@parent = story
				@alibi_requested = false
				super()
			end
			def post_initialize
				super
				personify
				@name = proper_name.first
				@longname = proper_name.full
				# TODO: Randomize the zone
				@zone = Zone.new
				waypoint = Waypoint.new :parent => zone,
					:name => 'driveway',
					:location => "#{proper_name}'s house"
				living_room = Room.new :parent => zone,
					:name => "living room"
				living_room.connect waypoint, "west"
				self.parent = living_room
				# TODO: Randomize containers
				Container.new :name => "wastebasket", :synonyms => "trash can basket", :parent => living_room, :image => 'wastebasket.png'
				@known = false
				@alibi_requested = false
			end
			def description
				"#{proper_name} is #{physical_description}"
			end
			def known?
				@known
			end
			def located?
				(@zone.parent == story)
			end
			def know
				@known = true
			end
			def locate
				@zone.parent = story
			end
			def alibi_requested?
				@alibi_requested
			end
			def alibi_requested
				@alibi_requested = true
			end
			def alibi_status
				if alibi_requested? != true
					return ALIBI_UNKNOWN
				end
				if @alibi.alibi_requested? == false
					return ALIBI_UNCONFIRMED
				end
				if @alibi.alibi == self
					return ALIBI_REAL
				end
				return ALIBI_FAKE
			end
			def default_map_command
				"^look #{self.longname}"
			end
		end
		class InstantLead < Item
			attr_accessor :suspect
		end
		class Clue < Item
			attr_accessor :story, :suspect
			def analyzed?
				if @analyzed == nil
					@analyzed = false
				end
				@analyzed
			end
			def analyze
				@analyzed = true
			end
		end
		class Weapon < Clue
		
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
