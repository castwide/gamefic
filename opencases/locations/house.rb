east_5 = Portal.create(
	:name => 'east',
	:longname => 'east',
	:description => 'Nothing special.',
	:synonyms => ''
)

second_floor_hallway = Room.create(
	:name => 'second floor hallway',
	:longname => 'second floor hallway',
	:description => 'Nothing special.',
	:synonyms => ''
)

east_4 = Portal.create(
	:name => 'east',
	:longname => 'east',
	:description => 'Nothing special.',
	:synonyms => ''
)

east_3 = Portal.create(
	:name => 'east',
	:longname => 'east',
	:description => 'Nothing special.',
	:synonyms => ''
)

east_2 = Portal.create(
	:name => 'east',
	:longname => 'east',
	:description => 'Nothing special.',
	:synonyms => ''
)

bathroom = Room.create(
	:name => 'bathroom',
	:longname => 'bathroom',
	:description => 'Nothing special.',
	:synonyms => ''
)

guest_bedroom = Room.create(
	:name => 'guest bedroom',
	:longname => 'guest bedroom',
	:description => 'Nothing special.',
	:synonyms => ''
)

north_4 = Portal.create(
	:name => 'north',
	:longname => 'north',
	:description => 'Nothing special.',
	:synonyms => ''
)

north_3 = Portal.create(
	:name => 'north',
	:longname => 'north',
	:description => 'Nothing special.',
	:synonyms => ''
)

north_2 = Portal.create(
	:name => 'north',
	:longname => 'north',
	:description => 'Nothing special.',
	:synonyms => ''
)

back_yard = Room.create(
	:name => 'back yard',
	:longname => 'back yard',
	:description => 'Nothing special.',
	:synonyms => ''
)

north = Portal.create(
	:name => 'north',
	:longname => 'north',
	:description => 'Nothing special.',
	:synonyms => ''
)

south_4 = Portal.create(
	:name => 'south',
	:longname => 'south',
	:description => 'Nothing special.',
	:synonyms => ''
)

south_3 = Portal.create(
	:name => 'south',
	:longname => 'south',
	:description => 'Nothing special.',
	:synonyms => ''
)

south_2 = Portal.create(
	:name => 'south',
	:longname => 'south',
	:description => 'Nothing special.',
	:synonyms => ''
)

master_bedroom = Room.create(
	:name => 'master bedroom',
	:longname => 'master bedroom',
	:description => 'Nothing special.',
	:synonyms => ''
)

west = Portal.create(
	:name => 'west',
	:longname => 'west',
	:description => 'Nothing special.',
	:synonyms => ''
)

driveway = Room.create(
	:name => 'driveway',
	:longname => 'driveway',
	:description => 'Nothing special.',
	:synonyms => ''
)

front_porch = Room.create(
	:name => 'front porch',
	:longname => 'front porch',
	:description => 'Nothing special.',
	:synonyms => ''
)

living_room = Room.create(
	:name => 'living room',
	:longname => 'living room',
	:description => 'Nothing special.',
	:synonyms => ''
)

east = Portal.create(
	:name => 'east',
	:longname => 'east',
	:description => 'Nothing special.',
	:synonyms => ''
)

kitchen = Room.create(
	:name => 'kitchen',
	:longname => 'kitchen',
	:description => 'Nothing special.',
	:synonyms => ''
)

west_5 = Portal.create(
	:name => 'west',
	:longname => 'west',
	:description => 'Nothing special.',
	:synonyms => ''
)

west_4 = Portal.create(
	:name => 'west',
	:longname => 'west',
	:description => 'Nothing special.',
	:synonyms => ''
)

south = Portal.create(
	:name => 'south',
	:longname => 'south',
	:description => 'Nothing special.',
	:synonyms => ''
)

down = Portal.create(
	:name => 'down',
	:longname => 'down',
	:description => 'Nothing special.',
	:synonyms => ''
)

west_3 = Portal.create(
	:name => 'west',
	:longname => 'west',
	:description => 'Nothing special.',
	:synonyms => ''
)

west_2 = Portal.create(
	:name => 'west',
	:longname => 'west',
	:description => 'Nothing special.',
	:synonyms => ''
)

study = Room.create(
	:name => 'study',
	:longname => 'study',
	:description => 'Nothing special.',
	:synonyms => ''
)

front_lawn = Room.create(
	:name => 'front lawn',
	:longname => 'front lawn',
	:description => 'Nothing special.',
	:synonyms => ''
)

up = Portal.create(
	:name => 'up',
	:longname => 'up',
	:description => 'Nothing special.',
	:synonyms => ''
)

east_5.parent = second_floor_hallway
east_4.parent = front_porch
east_3.parent = living_room
east_2.parent = kitchen
north_4.parent = second_floor_hallway
north_3.parent = bathroom
north_2.parent = front_lawn
north.parent = study
south_4.parent = guest_bedroom
south_3.parent = second_floor_hallway
south_2.parent = living_room
west.parent = back_yard
east.parent = driveway
west_5.parent = master_bedroom
west_4.parent = front_porch
south.parent = driveway
down.parent = second_floor_hallway
west_3.parent = living_room
west_2.parent = kitchen
up.parent = living_room
east_5.destination = master_bedroom
east_4.destination = living_room
east_3.destination = kitchen
east_2.destination = back_yard
north_4.destination = guest_bedroom
north_3.destination = second_floor_hallway
north_2.destination = driveway
north.destination = living_room
south_4.destination = second_floor_hallway
south_3.destination = bathroom
south_2.destination = study
west.destination = kitchen
east.destination = front_porch
west_5.destination = second_floor_hallway
west_4.destination = driveway
south.destination = front_lawn
down.destination = living_room
west_3.destination = front_porch
west_2.destination = living_room
up.destination = second_floor_hallway
