################################################################################
# COMMON ACTIONS
#
# These are some actions that might typically be performed in a game.
################################################################################

# Look at the room
Action.new("look", nil, nil, nil) { |actor, target, tool|
	actor.execute("look", actor.parent, nil)
}

# Look at an entity
Action.new("look", Item, nil, nil) { |actor, target, tool|
	if target.description.to_s != ""
		actor.tell target.description
	else
		actor.tell "You see nothing special about #{target.longname}."
	end
}

Action.new("look", Entity, nil, nil) { |actor, target, tool|
	if actor == target
		actor.tell "(Your description)"
	end
	if target.description.to_s != ""
		actor.tell target.description
	else
		actor.tell "(#{target.longname}) You see nothing special."
	end
	if target.respond_to?("opened?")
		if target.opened?
			actor.tell("#{target.longname.cap_first} is open.")
		else
			actor.tell("#{target.longname.cap_first} is closed.")
		end
	end
}

# Look at a container
Action.new("look", Container, nil, nil) { |actor, target, tool|
	if target.description.to_s != ""
		actor.tell target.description
	else
		actor.tell "You see nothing special about #{target.longname}."
	end
	if target.opened?
		actor.tell "#{target.longname.cap_first} is open."
	else
		actor.tell "#{target.longname.cap_first} is closed."
	end
}

# No target to look at
Action.new("look", String, nil, nil) { |actor, target, tool|
	actor.tell "You do not see any '#{target}' here."
}

# Look at the room
Action.new("look", Room, nil, nil) { |actor, target, tool|
	actor.tell target.description
	chars = target.children.delete_if {|c| c.kind_of?(Character) == false} - [actor]
	if chars.length > 0
		actor.tell "Others here: #{chars.join(", ")}"
	end
	items = target.children.delete_if {|c| c.kind_of?(Item) == false}
	if items.length > 0
		actor.tell "Visible items: #{items.join(", ")}"
	end
	exits = target.children.delete_if {|c| c.kind_of?(Portal) == false}
	if exits.length > 0
		actor.tell "Obvious exits: #{exits.join(", ")}"
	end
}

# Look inside something
Action.new("search", Container, nil, nil) { |actor, target, tool|
	if target.opened?
		contained = target.children.of_type(Entity)
		if contained.length > 0
			actor.tell "Inside #{target.longname}: #{contained.join(", ")}"
		else
			actor.tell "#{target.longname.cap_first} is empty."
		end
	else
		actor.tell "#{target.longname.cap_first} is not open."
	end
}

Action.new("search", Entity, nil, nil) { |actor, target, tool|
	actor.tell "You see nothing special."
}

Action.new("search", String, nil, nil) { |actor, target, tool|
	actor.tell "You do not see any '#{target} here."
}

Action.new("lookin", String, Container, nil) { |actor, target, tool|
	found = game.entities.bind(target, tool)
	if found != nil
		game.execute(actor, "look", found, tool)
	else
		actor.tell "You do not see any '#{target}' in #{tool}."
	end
}

# Go somewhere
Action.new("go", Portal, nil, nil) { |actor, target, tool|
	if target.respond_to?("opened?") and target.opened? == false
		actor.tell "#{target.longname.cap_first} is closed."
	else
		actor.parent.tell "#{actor.longname.cap_first} leaves.", [actor]
		actor.parent = target.destination
		actor.tell "You go #{target.name}."
		actor.tell "Location: #{target.destination.name}"
		chars = target.destination.children.delete_if{|c| c.kind_of?(Character) == false} - [actor]
		if chars.length > 0
			actor.tell "Others here: #{chars.join(", ")}"
		end
		items = target.destination.children.delete_if{|c| c.kind_of?(Item) == false}
		if items.length > 0
			actor.tell "Visible items: #{items.join(", ")}"
		end
		exits = target.destination.children.delete_if{|c| c.kind_of?(Portal) == false}
		if exits.length > 0
			actor.tell "Obvious exits: #{exits.join(", ")}"
		end
		actor.parent.tell "#{actor.longname.cap_first} arrives.", [actor]
	end
}

# Not a valid exit
Action.new("go", Entity, nil, nil) { |actor, target, tool|
	actor.tell "#{target.longname.cap_first} is not an exit."
}

# Nowhere to go
Action.new("go", String, nil, nil) { |actor, target, tool|
	actor.tell "You cannot go '#{target}' from here."
}

# Get an item
Action.new("get", Entity, nil, nil) { |actor, target, tool|
	if target.parent == actor.parent
		if target.portable?
			target.parent = actor
			actor.tell "You take #{target.longname}."
		else
			actor.tell "You cannot take #{target.longname}."
		end
	elsif target.parent == actor
		actor.tell "You already have #{target.longname}."
	end
}

# Nothing to get
Action.new("get", String, nil, nil) { |actor, target, tool|
	if target == "all"
		possible = actor.parent.children.of_type(Item)
		if possible.length == 0
			actor.tell "You don't see anything you can pick up."
		else
			possible.each { |i|
				game.execute(actor, "get", i, nil)
			}
		end
	else
		gotten = false
		possible = actor.parent.children.of_type(Container)
		possible.each { |c|
			item = Entity.bind(target, c)
			if item.kind_of?(Entity)
				actor.execute("get", item, c)
				gotten = true
				break
			end
		}
		if gotten == false
			actor.tell "You do not see any '#{target}' here."
		end
	end
}

Action.new("get", Entity, Container, nil) { |actor, target, tool|
	if tool.opened? == false
		actor.tell "#{tool.longname.cap_first} is closed."
	else
		if target.parent == tool
			target.parent = actor
			actor.tell "You take #{target.longname} from #{tool.longname}."
		else
			actor.tell "#{target.longname.cap_first} is not inside #{tool.longname}."
		end
	end
}

Action.new("get", String, Container, nil) { |actor, target, tool|
	if tool.opened? == false
		actor.tell "#{tool.longname.cap_first} is closed."
	else
		found = game.entities.bind(target, tool)
		if found.kind_of?(Entity)
			game.execute(actor, "get", found, tool)
		else
			actor.tell "You do not see any '#{target}' in #{tool.longname}."
		end
	end
}

# Drop an item
Action.new("drop", Item, nil, nil) { |actor, target, tool|
	if target.parent == actor
		target.parent = actor.parent
		actor.tell "You drop #{target.longname}."
	else
		actor.tell "You are not carrying #{target.longname}."
	end
}

# Nothing to drop
Action.new("drop", String, nil, nil) { |actor, target, tool|
	actor.tell "You do not see any '#{target}' here."
}

Action.new("put", Entity, Container, nil) { |actor, target, tool|
	if target.parent != actor
		game.execute(actor, "get", target, nil)
	end
	if target.parent == actor
		if tool.opened?
			target.parent = tool
			actor.tell "You put #{target.longname} in #{tool.longname}."
		else
			actor.tell "#{tool.longname.cap_first} is closed."
		end
	end
}

Action.new("put", String, nil, nil) { |actor, target, tool|
	actor.tell "You do not have any '#{target}.'"
}

Action.new("put", Entity, String, nil) { |actor, target, tool|
	actor.tell "You do not see any '#{tool}' here."
}

Action.new("help", nil, nil, nil) { |actor, target, tool|
	case target.to_s
		when ""
			actor.tell "Enter \"help commands\" for a list of actions you can perform."
			#actor.tell "Enter \"help (verb)\" for more information on a particular action (e.g., \"help go\")"
		when "commands"
			actor.tell "The following commands are available: #{game.parser.list.join(", ")}"
		else
			actor.tell "Option '#{target}' not recognized.  Enter \"help\" for available options."
	end
}

Action.new("quit", nil, nil, nil) { |actor, target, tool|
	exit
}

Action.new("inventory", nil, nil, nil) { |actor, target, tool|
	inv = actor.children.of_type(Item)
	if inv.length > 0
		actor.tell "You are carrying: #{inv.join(", ")}"
	else
		actor.tell "You are not carrying anything."
	end
}

Action.new("open", Entity, nil, nil) { |actor, target, tool|
	if target.respond_to?('opened?')
		if target.opened?
			actor.tell "It is already open."
		else
			target.opened = true
			actor.tell "You open #{target.longname}."
		end
	else
		actor.tell "#{target.longname.cap_first} cannot be opened or closed."
	end
}

Action.new("open", String, nil, nil) { |actor, target, tool|
	case target
		when "n"
			actor.perform("open north")
		when "s"
			actor.perform("open south")
		when "w"
			actor.perform("open west")
		when "e"
			actor.perform("open east")
		when "nw"
			actor.perform("open northwest")
		when "sw"
			actor.perform("open southwest")
		when "ne"
			actor.perform("open northeast")
		when "se"
			actor.perform("open southeast")
		when "u"
			actor.perform("open up")
		when "d"
			actor.perform("open down")
		else
			actor.tell "You don't see any '#{target}' here."
	end
}

Action.new("close", String, nil, nil) { |actor, target, tool|
	case target
		when "n"
			actor.perform("close north")
		when "s"
			actor.perform("close south")
		when "w"
			actor.perform("close west")
		when "e"
			actor.perform("close east")
		when "nw"
			actor.perform("close northwest")
		when "sw"
			actor.perform("close southwest")
		when "ne"
			actor.perform("close northeast")
		when "se"
			actor.perform("close southeast")
		when "u"
			actor.perform("close up")
		when "d"
			actor.perform("close down")
		else
			actor.tell "You don't see any '#{target}' here."
	end
}

Action.new("close", Entity, nil, nil) { |actor, target, tool|
	if target.respond_to?('opened?')
		if target.opened?
			target.opened = false
			actor.tell "You close #{target.longname}."
		else
			actor.tell "It is already closed."
		end
	else
		actor.tell "#{target.longname.cap_first} cannot be opened or closed."
	end
}

Action.new("talk", Entity, nil, nil) { |actor, target, tool|
	actor.tell "Are you trying to talk to #{target.longname}?"
}

Action.new("talk", Character, nil, nil) { |actor, target, tool|
	actor.tell "#{target.longname.cap_first} has nothing to say."
}

Action.new("show", Entity, Entity, nil) { |actor, target, tool|
	actor.tell "Nothing happens."
}

Action.new("show", Entity, nil, nil) { |actor, target, tool|
	actor.tell "Who do you want to show #{target.longname} to?"
}

Action.new("show", String, nil, nil) { |actor, target, tool|
	actor.tell "You don't have a '#{target}' to show."
}

Action.new("show", Entity, Character, nil) { |actor, target, tool|
	if target == tool
		actor.tell "What are you, a mirror?"
	else
		actor.tell "#{tool.longname.cap_first} does not appear interested in #{target.longname}."
	end
}

Action.new("echo", String, nil, nil) { |actor, target, tool|
	actor.tell target
}

###############################################################################
# COMMON COMMANDS
#
# These are parser definitions for typical commands a player might use.
###############################################################################

# Help commands
Parser.add("help", "help")
Parser.add("help {option}", "help {option}")

# Game controls
Parser.add("quit", "quit")

# Look commands
Parser.add("look", "look")
Parser.add("look around", "look")
Parser.add("l", "look")
Parser.add("look {object}", "look {object}")
Parser.add("look at {object}", "look {object}")
Parser.add("l {object}", "look {object}")
Parser.add("examine {object}", "look {object}")
Parser.add("exam {object}", "look {object}")

Parser.add("look in {object}", "search {object}")
Parser.add("look inside {object}", "search {object}")
Parser.add("l in {object}", "search {object}")
Parser.add("l inside {object}", "search {object}")
Parser.add("search {object}", "search {object}")

Parser.add("look {object} in {container}", "lookin {object} {container}")
Parser.add("look {object} inside {container}", "lookin {object} {container}")
Parser.add("look at {object} in {container}", "lookin {object} {container}")
Parser.add("look at {object} inside {container}", "lookin {object} {container}")
Parser.add("l {object} in {container}", "lookin {object} {container}")
Parser.add("l {object} inside {container}", "lookin {object} {container}")
Parser.add("examine {object} in {conatiner}", "lookin {object} {container}")
Parser.add("exam {object} in {conatiner}", "lookin {object} {container}")

# Get commands
Parser.add("get {object}", "get {object}")
Parser.add("take {object}", "get {object}")
Parser.add("pick up {object}", "get {object}")

Parser.add("get {object} from {container}", "get {object} {container}")
Parser.add("take {object} from {container}", "get {object} {container}")
Parser.add("get {object} from inside {container}", "get {object} {container}")
Parser.add("take {object} from inside {container}", "get {object} {container}")
Parser.add("get {object} in {container}", "get {object} {container}")
Parser.add("take {object} in {container}", "get {object} {container}")
Parser.add("get {object} out of {container}", "get {object} {container}")
Parser.add("take {object} out of {container}", "get {object} {container}")

# Drop commands
Parser.add("drop {object}", "drop {object}")
Parser.add("put down {object}", "drop {object}")

Parser.add("put {object} in {container}", "put {object} {container}")
Parser.add("put {object} inside {container}", "put {object} {container}")
Parser.add("drop {object} in {container}", "put {object} {container}")
Parser.add("drop {object} inside {container}", "put {object} {container}")

# Inventory
Parser.add("inventory", "inventory")
Parser.add("inv", "inventory")
Parser.add("i", "inventory")

# Common directions for portals
Parser.add("go {direction}", "go {direction}")
Parser.add("go to {direction}", "go {direction}")
Parser.add("north", "go north")
Parser.add("n", "go north")
Parser.add("south", "go south")
Parser.add("s", "go south")
Parser.add("west", "go west")
Parser.add("w", "go west")
Parser.add("east", "go east")
Parser.add("e", "go east")
Parser.add("northwest", "go northwest")
Parser.add("nw", "go northwest")
Parser.add("northeast", "go northeast")
Parser.add("southwest", "go southwest")
Parser.add("sw", "go southwest")
Parser.add("southeast", "go southeast")
Parser.add("se", "go southeast")
Parser.add("up", "go up")
Parser.add("u", "go up")
Parser.add("down", "go down")
Parser.add("d", "go down")
Parser.add("walk {direction}", "go {direction}")
Parser.add("run {direction}", "go {direction}")
Parser.add("head {direction}", "go {direction}")

Parser.add("open {container}", "open {container}")
Parser.add("close {container}", "close {container}")

Parser.add("talk {character}", "talk {character}")
Parser.add("speak {character}", "talk {character}")
Parser.add("talk to {character}", "talk {character}")
Parser.add("talk to {character} about {subject}", "talk {character} {subject}")
Parser.add("ask {character} about {subject}", "talk {character} {subject}")
Parser.add("tell {character} about {subject}", "talk {character} {subject}")
Parser.add("speak to {character}", "talk {character}")
Parser.add("speak to {character} about {subject}", "talk {character} {subject}")
Parser.add("say {subject} to {character}", "talk {character} {subject}")

Parser.add("show {object} to {character}", "show {object} {character}")
Parser.add("show {character} the {object}", "show {object} {character}")
Parser.add("let {character} see {object}", "show {object} {character}")
Parser.add("let {character} look at {object}", "show {object} {character}")
Parser.add("let {character} look {object}", "show {object} {character}")
Parser.add("let {character} examine {object}", "show {object} {character}")
Parser.add("let {character} exam {object}", "show {object} {character}")
Parser.add("make {character} see {object}", "show {object} {character}")
Parser.add("make {character} look at {object}", "show {object} {character}")
Parser.add("make {character} look {object}", "show {object} {character}")
Parser.add("make {character} examine {object}", "show {object} {character}")
Parser.add("make {character} exam {object}", "show {object} {character}")
Parser.add("echo {text}", "echo {text}")

Action.set_passive "look"
Action.set_passive "help"
Action.set_passive "inventory"
Action.set_passive "quit"
Action.set_passive "talk"
Action.set_passive "show"
Action.set_passive "echo"
