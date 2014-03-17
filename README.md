#Gamefic

A Ruby Adventure Engine

Gamefic is a system for developing and playing adventure games.

The core Gamefic library and executable are available as a Ruby gem:

    gem install gamefic

**Note**: The examples in this README assume you are testing with a checkout of
the Git repo, so they reference the playtest script instead of the binary in
the gem.

# Running the Examples

The Git repo includes several demo games in the examples directory. You can
run them from the command line like so:

    ./playtest examples/simple.rb

The simple.rb example consists of a room and a closet. The room has a book in
it. Try the following commands to see how it works:

    look
	look at book
	pick up book
	read book
	drop book

# Game Commands

The Gamefic library provides a collection of commands that are common in most
text adventures, including the following:

    go [north, south, west, east]
    look [item]
    get [item]
    inventory
    drop [item]

It also implements common synonyms; for example, any of the following work the
same as "get book":

    take book
    pick up book
    pick book up

## Command Shortcuts

The common directions you can go--north, south, west, east, up, and down--can
be shortened to their first letter. For example, "n" means "go north."
Additionally, northwest, northeast, southwest, and southeast can be referenced
as nw, ne, sw, and se respectively.

Some other shortcuts:

    i = inventory
	x or exam = look (examine)

# Games on the Command Line

The Gamefic repo includes a command-line script that invokes the Gamefic
library with default action and entity definitions. It accepts one argument,
the name of a file that contains game data. Example:

	cd /path/to/gamefic
    ./playtest examples/example.rb

The default game engine is a turn-based terminal program. Executing the above
command drops you to a command line in-game, ready for you to enter an action.
The example.rb game provides a very simple demonstration of what you can do
with the default game environment.

# Writing Your First Game

To make your own game, all you need to do is create a script to load with the
play command. Create a file in your gamefic directory named "tiny.rb" that
contains the following:

    apartment = make Room, :name => "apartment", :description => "You are in a tiny one-room apartment."

    introduction do |player|
        player.parent = apartment
	end

Run the script from the command line:

    ./playtest tiny.rb

The script will drop you into a game prompt. There's not much you can do except look around:

    >look
	You are in a tiny one-room apartment.
	Obvious exits: none
	>

"Look" is one of the actions defined in the action_ext library. As you can see,
it outputs the room's description and gives you a list of exits.

Right now there's not much you can do in this game other than "look" and "quit." We
can make things a little more interesting by putting something in the apartment.
Add this code to tiny.rb:

    pencil = make Item, :name => "pencil", :description => "A plain old No. 2 yellow.", :parent => apartment

Play the script again. Now the apartment contains an item you can manipulate.

	> look
	Apartment
	You are in a tiny one-room apartment.
	Visible items: pencil
	Obvious exits: none
	> look at pencil
	A plain old No. 2 yellow.
	> take pencil
	You take pencil.
	> inventory
	pencil
	> drop pencil
	You drop pencil.
	> quit

## The Script Code

Let's take a closer look at the methods we used in the script.

### make

The make method adds an entity to your story. In this demo, we added two types
of entities: a Room and an Item. The first argument is the entity type and the
second is an object containing the entity's properties. Note that one of the
pencil's properties is parent, which is set to the apartment.

### introduction

The introduction method accepts a proc that will be executed when the game
begins. In this example, it just puts the player in the room, but it could
also output an introductory message:

    player.tell "Welcome to your cozy little apartment!"

### Entity Types

We've created two types of entities for this demo, a Room and an Item. These
are likely the most common entity types you'll use while creating a game, but
there are several others defined in the entity_ext library. Here's a brief
explanation of each:

#### Container

An entity that can contain other items. Typically, anything that a player can
carry (i.e., an Item) can be put inside a Container.

#### Fixture

A stationary object, such as a large piece of furniture. Fixtures are included
in a room's list of visible items, but players cannot pick them up.

#### Item

Something that players can carry.

#### Portal

A fixed Entity that players can use to travel from Room to Room. Typically, a
Portal is named for the direction it represents, eg., north, south, west, etc.

#### Room

A location that players and other Entities can occupy.

#### Scenery

An Entity that can provide a description when players "look" at it. Unlike
Fixtures, Scenery is not included in a room's list of visible items.

## Adding More Entities

Let's explore some of the other Entity types by adding more stuff to the
tiny.rb demo.

    bed = make Fixture, :name => "bed", :description => "A comfy little twin bed.", :parent => apartment
	
    cupboard = make Container, :name => "cupboard", :description => "A small wooden cupboard.", :parent => apartment

    closet = make Room, :name => "closet", :description => "This closet is surprisingly spacious for such a small apartment."
    closet.connect room, "east"

Run the demo again and try interacting with the new Entities. Among the new
actions you can perform are walking into the closet ("west" from the apartment)
and putting the pencil in the cupboard.

## Connecting Rooms

Note the additional line of code following the creation of the closet:

    closet.connect apartment, "east"

The connect method creates a Portal between this Room and another. The first
argument is the Room to be connected and the second argument is the name of the
Portal. By default, the connect method creates another Portal in the
destination Room that leads back to this one. In this case, the apartment will
have a Portal named "west" that leads to the closet. The names that can be used
for bidirectional Portals are north, south, west, east, up, northwest,
northeast, southwest, southeast, up, and down.

## Actions

Now let's try making a new action for players to perform. Add the following
code to the demo:

    respond :lie_on, Query.new(:siblings, bed) do |actor, bed|
	    actor.tell "You take a short nap. That was refreshing!"
	end

Now there's a new command you can use in the game.

    > lie on bed
    You take a short nap. That was refreshing!

How does all that code work? Bear with me, because this gets a little weird.

### The Command Symbol

The first argument to the action method is the symbol used to identify it.
In this case, the symbol is :lie_on. The game engine translates the underscore
into a space, so the player can invoke this action by entering "lie on."

### The Query Object

The second argument in our example is a Query object that the game's command
parser uses to identify an Entity in the game. The :siblings symbol means that
it should search the player's siblings, i.e., the other Entities in the Room.

Additional arguments to the Query object filter the scope of Entities that
trigger the Action. In this case, bed means that the Action can only be
performed on the bed. If the player references any other Entity (e.g., "lie on
cupboard"), the Action's proc will not be executed.

### The Action's Proc

The final argument is the proc to execute in response to the player's command.
The proc's first argument is always the player Entity. The remaining arguments
are the Entities returned by each Query.

This example's proc code simply sends a message to the player via the tell method.

## Syntaxes

Right now, the only way for the player to lie on the bed is to enter "lie on
bed." What if the player words it differently?

    > lie down on bed
    I don't know what you mean by 'lie down on bed.'

Trying to guess the exact phrasing the game expects can be frustrating. To
keep your game fun and immersive, it's a good idea to support multiple
Syntaxes for actions. We can make "lie down" work with the following line of
code:

    xlate "lie down on :thing", :lie_on, :thing

This code tells the game to accept a Syntax that matches "lie down on :thing"
where :thing is a placeholder for a Query. The action the Syntax executes
is :lie_on. The remainder of the arguments tell the game how to order the
placeholders when executing the Action's proc. In this case, the only
placeholder is :thing.

Now "lie down on" works the same as "lie on":

    > lie down on bed
    You take a short nap. That was refreshing!

Here are a couple more syntaxes that might prove useful:

    xlate "sleep on :thing", :lie_on, :thing
	xlate "sleep", :lie_on, "bed"

The first Syntax allows the player to enter "sleep on bed."

The second Syntax is a little different. If the player simply enters "sleep"
without specifying where, the Syntax assumes that the argument to pass to the
Action should be "bed."

    > sleep
    You take a short nap. That was refreshing!

Great! But what if there's not a bed around?

	> go west
	You go west.
	Closet
	Obvious exits: east
	> sleep
	I don't know what you mean by 'sleep.'

That's just about the correct behavior we want: the player needs to
be near a bed to sleep. Unfortunately, the game's response is a little
misleading: "I don't know what you mean by 'sleep.'" It actually knows what
sleep means, but only if there's a bed in the room. Without a bed, the game
will never execute the lie_on Action.

Let's fix this with another Action:

	respond :sleep do |actor|
		if actor.parent.children.that_are(bed).length > 0
			actor.perform "lie on bed"
		else
			actor.tell "There's not a bed in here."
		end
	end

This Action will let the player sleep as long as he's in the room with the bed
in it. We can add a few more Syntaxes like so:

	xlate "go to sleep", :sleep
	xlate "rest", :sleep
	xlate "snooze", :sleep
