import 'standard'
import 'hello'

room = make Room, :name => "a room", :description => "Just a room with four walls."

closet = make Room, :name => "a closet", :description => "A walk-in closet. The door leads west."
closet.connect room, "west"

book = make Item, :name => "a book", :description => "A copy of The Count of Monte Cristo.", :synonyms => "count of monte cristo alexandre dumas", :parent => room

respond :read, Query::Children.new(book) do |actor, book|
	actor.tell "\"On the 24th of February, 1810, the look-out at Notre-Dame de la Garde signalled the three-master, the Pharaon from Smyrna, Trieste, and Naples.\""
end

respond :read, Query::Siblings.new(book) do |actor, book|
	actor.tell "You need to pick it up first."
end

respond :read, Query::Text.new() do |actor, thing|
	actor.tell "You don't have anything called '#{thing}' to read."
end

introduction do |player|
	player.parent = room
	player.tell "This is a simple example of Gamefic."
end
