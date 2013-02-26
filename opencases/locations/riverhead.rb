require "libx/murder"
require "libx/graphical"

declare "scripts/look.rb"
declare "scripts/traversal.rb"
declare "scripts/carshuttle.rb"
declare "scripts/inventory.rb"
declare "scripts/container.rb"

parking_garage = Waypoint.new :name => 'parking garage', :parent => story, :image => 'squadroom/parking.png'

parking_garage.longname = "the parking garage"
parking_garage.location = "City Police Station"
parking_garage.description = 'You are in the parking garage beneath the police station. A doorway to the east leads to the stairwell.'

stairwell = Room.new :name => 'stairwell', :parent => story

stairwell.connect parking_garage, "west"
stairwell.description = 'The dingy stairwell connecting the underground parking garage to the police station upstairs.'

lobby = Room.new :name => 'lobby',
	:parent => story, :image => 'squadroom/tile.png'
lobby.connect stairwell, "down"

front_desk = Room.new :name => 'front desk', :parent => story, :image => 'squadroom/tile.png'
front_desk.connect lobby, "south"

squad_room = Room.new :name => 'squad room', :parent => story
squad_room.connect lobby, "west"
squad_room.description = 'The squad room is never quiet. Detectives man the phones, talk to witnesses, and discuss open cases with prosecutors.'

cabinet = Container.new :name => 'filing cabinet', :parent => squad_room

folder = Item.new :name => 'folder', :parent => cabinet

assignment_room = Room.new :name => 'assignment room', :parent => story
assignment_room.connect squad_room, "west"
assignment_room.longname = "the assignment room"
assignment_room.description = "The bulletin board on the north wall of the squad room displays open cases waiting for a detective's attention. Look at the board to see the list."

case_board = Fixture.new :name => 'case board', :image => 'caseboard.png', :parent => assignment_room
case_board.longname = "the squad's open case list"
case_board.synonyms = "bulletin board caseboard"
case_board.map_command = "look #{case_board.longname}"

captains_office = Room.new :parent => story
captains_office.name = "Captain's office"
captains_office.longname = "the Captain's office"
captains_office.description = 'The only private office in the squad room belongs to the Captain. Stacks of paper threaten to crack his desktop.'
captains_office.connect squad_room, "south"

break_room = Room.new :name => 'break room', :parent => story, :image => 'squadroom/breakroom.png'
break_room.connect squad_room, "north"
break_room.description = 'Snack machines, a microwave, a water cooler, and the worst coffee in the city.'

officer = Character.new :name => 'policeman', :longname => 'a policeman', :parent => break_room, :image => 'police.png', :story => self
officer.on_update do |officer|
	if rand(30) == 1
		portals = officer.parent.children.that_are(Portal)
		officer.perform "go #{portals.random.name}"
	end
end

paperwork = Scenery.new :name => 'paperwork'
paperwork.extend Portable
paperwork.parent = captains_office
paperwork.description = 'Correspondence, legal forms, bureaucratic red tape... all the stuff your Captain deals with so the detectives can stay busy solving crimes.'
paperwork.synonyms = 'documents folders papers stacks'

action :look, query(:siblings, case_board) do |actor, board|
	featured = false
	Series.instance.episodes.each { |episode|
		if episode.features?(actor)
			featured = true
			break
		end
	}
	if featured
		actor.tell "You're already on a case."
	else
		episode = Murder.new
		episode.introduce actor	
	end
end

introduction do |player|
	player.parent = parking_garage
end
