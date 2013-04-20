# Load a base set of useful Entity subclasses.
#
# Base entities include the following:
# * Room: a navigable location in the game
# * Portal: an exit from one room to another
# * Item: a portable object
# * Container: an entity that can hold other entities
# * Fixture: a stationary object in a room
# * Scenery: something that is not vital to gameplay but provides atmosphere
#
# Require gamefic/action_ext for a base set of commands for interacting with
# entities.

Dir[File.dirname(__FILE__) + '/entity_ext/*.rb'].each do |file|
	require file
end
