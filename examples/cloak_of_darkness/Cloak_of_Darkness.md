## The Cloak of Darkness 

Cloak of Darkness has its own site at http://www.firthworks.com/roger/cloak/ and there's also a [Cloak of Darkness page on IF Wiki](http://www.ifwiki.org/index.php/Cloak_of_Darkness).

### The spec

This section is quoted verbatim from [Roger Firth's Cloak of Darkness site](http://www.firthworks.com/roger/cloak/). 

The various implementations have been made as similar as possible. That is, things like object names and room descriptions should be identical, and the general flow of the game should be pretty comparable. Having said that, the games are implemented using the native capabilities of the various systems, using features that a beginner might be expected to master; there shouldn't be any need to resort to assembler routines, library hacks, or other advanced techniques. The target is to write naturally and simply, while sticking as closely as possible to the goal of making the games directly equivalent.

"Cloak of Darkness" is not going to win prizes for its prose, imagination or subtlety. Or scope: it can be played to a successful conclusion in five or six moves, so it's not going to keep you guessing for long. (On the other hand, it may qualify as the most widely-available game in the history of the genre.) There are just three rooms and three objects.

* The Foyer of the Opera House is where the game begins. This empty room has doors to the south and west, also an unusable exit to the north. There is nobody else around.
* The Bar lies south of the Foyer, and is initially unlit. Trying to do anything other than return northwards results in a warning message about disturbing things in the dark.
* On the wall of the Cloakroom, to the west of the Foyer, is fixed a small brass hook.
* Taking an inventory of possessions reveals that the player is wearing a black velvet cloak which, upon examination, is found to be light-absorbent. The player can drop the cloak on the floor of the Cloakroom or, better, put it on the hook.
* Returning to the Bar without the cloak reveals that the room is now lit. A message is scratched in the sawdust on the floor.
* The message reads either "You have won" or "You have lost", depending on how much it was disturbed by the player while the room was dark.
* The act of reading the message ends the game.


### inform 7 source

The Inform 7 is in no way the canonical version, it's just one that's very readable (and I know Inform 7). The Inform 7 code is on the cloak of darkness site, included after the inform 6 source in the "inform" heading.


	"Cloak of Darkness"

	The story headline is "A basic IF demonstration."

	The maximum score is 2.

	[Whatever room we define first becomes the starting room of the game,
	in the absence of other instructions:]

	Foyer of the Opera House is a room.  "You are standing in a spacious hall,
	splendidly decorated in red and gold, with glittering chandeliers overhead.
	The entrance from the street is to the north, and there are doorways south and west."

	Instead of going north in the Foyer, say "You've only just arrived, and besides,
	the weather outside seems to be getting worse."

	[We can add more rooms by specifying their relation to the first room.
	Unless we say otherwise, the connection will automatically be bidirectional,
	so "The Cloakroom is west of the Foyer" will also mean "The Foyer is east of the Cloakroom":]

	The Cloakroom is west of the Foyer.
	"The walls of this small room were clearly once lined with hooks, though now only one remains.
	The exit is a door to the east."

	In the Cloakroom is a supporter called the small brass hook.
	The hook is scenery. Understand "peg" as the hook.

	[Inform will automatically understand any words in the object definition
	("small", "brass", and "hook", in this case), but we can add extra synonyms
	with this sort of Understand command.]

	The description of the hook is "It's just a small brass hook,
	[if something is on the hook]with [a list of things on the hook]
	hanging on it[otherwise]screwed to the wall[end if]."

	[This description is general enough that, if we were to add other hangable items
	to the game, they would automatically be described correctly as well.]

	The Bar is south of the Foyer. The printed name of the bar is "Foyer Bar".
	The Bar is dark.  "The bar, much rougher than you'd have guessed
	after the opulence of the foyer to the north, is completely empty.
	There seems to be some sort of message scrawled in the sawdust on the floor."

	The scrawled message is scenery in the Bar. Understand "floor" or "sawdust" as the message.

	Neatness is a kind of value. The neatnesses are neat, scuffed, and trampled.
	The message has a neatness. The message is neat.

	[We could if we wished use a number to indicate how many times
	the player has stepped on the message, but Inform also makes it easy
	to add descriptive properties of this sort, so that the code remains readable
	even when the reader does not know what "the number of the message" might mean.]

	Instead of examining the message:
	    increase score by 1;
	    say "The message, neatly marked in the sawdust, reads...";
	    end the game in victory.

	[This second rule takes precedence over the first one whenever the message is trampled.
	Inform automatically applies whichever rule is most specific:]

	Instead of examining the trampled message:
	    say "The message has been carelessly trampled, making it difficult to read.
	    You can just distinguish the words...";
	    end the game saying "You have lost".

	[This command advances the state of the message from neat to scuffed
	and from scuffed to trampled. We can define any kinds of value we like
	and advance or decrease them in this way:]

	Instead of doing something other than going in the bar when in darkness:
	    if the message is not trampled, change the neatness of the message
	    to the neatness after the neatness of the message;
	    say "In the dark? You could easily disturb something."

	Instead of going nowhere from the bar when in darkness:
	    now the message is trampled;
	    say "Blundering around in the dark isn't a good idea!"

	[This defines an object which is worn at the start of play.
	Because we have said the player is wearing the item, Inform infers that it is clothing
	and can be taken off and put on again at will.]

	The player wears a velvet cloak. The cloak can be hung or unhung.
	Understand "dark" or "black" or "satin" as the cloak.
	The description of the cloak is "A handsome cloak,
	of velvet trimmed with satin, and slightly splattered with raindrops.
	Its blackness is so deep that it almost seems to suck light from the room."

	Carry out taking the cloak:
	    now the bar is dark.

	Carry out putting the unhung cloak on something in the cloakroom:
	    now the cloak is hung;
	    increase score by 1.

	Carry out putting the cloak on something in the cloakroom:
	    now the bar is lit.

	Carry out dropping the cloak in the cloakroom:
	    now the bar is lit.

	Instead of dropping or putting the cloak on when the player is not in the cloakroom:
	    say "This isn't the best place to leave a smart cloak lying around."

	When play begins:
	    say "[paragraph break]Hurrying through the rainswept November night,
	    you're glad to see the bright lights of the Opera House.
	    It's surprising that there aren't more people about but, hey,
	    what do you expect in a cheap demo game...?"

	Understand "hang [something preferably held] on [something]" as putting it on.

	Test me with "s / n / w / inventory / hang cloak on hook / e / s / read message".


