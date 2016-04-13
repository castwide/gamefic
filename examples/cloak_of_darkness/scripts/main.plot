script 'standard'
script 'test'

# Cloak of Darkness for Gamefic. 
# Gamefic implementation by Peter Orme. 
# Version 1.0.0 / 1 April 2014
# 
# Cloak of Darkness is a "hello world" example for interactive fiction.
# See http://www.firthworks.com/roger/cloak/
# Based on the Inform7 implementation by Emily Short and Graham Nelson.
#
# Version 2.0.0 / 12 July 2014 by Fred Snyder
# Updated to use new features of Gamefic.

# The Foyer is where the player starts. 

foyer = make Room, 
  :name => "Foyer of the Opera House", 
  :description => "You are standing in a spacious hall, splendidly decorated in red and gold, with glittering chandeliers overhead. The entrance from the street is to the north, and there are doorways south and west."


# There's a "fake" door north, which the player can never go through.

frontDoor = make Portal,
  :name => "north",
  :description => "The door to the street.", 
  :parent => foyer,
  :proper_named => true

respond :go, Query::Siblings.new(frontDoor) do |actor, dest|
  actor.tell "You've only just arrived, and besides, the weather outside seems to be getting worse."
end


# The cloakroom is west of the foyer. 

cloakroom = make Room, 
  :name => "Cloakroom",
  :description => "The walls of this small room were clearly once lined with hooks, though now only one remains. The exit is a door to the east."

foyer.connect cloakroom, "west"


# In the cloak room there's a hook where we can hang the cloak. 
# It doesn't need a new class, it's just a fixture which responds to "put on" and "look".

hook = make Supporter, 
  :name => "a small brass hook",
  :description => "It's just a brass hook.",
  :parent => cloakroom, 
  :synonyms => "peg"

respond :look, Query::Family.new(hook) do |actor, hook|
  if hook.children.empty?
    actor.tell "It's just a brass hook, screwed to the wall."
  else
    actor.tell "It's just a brass hook, with #{a hook.children[0]} hanging on it, screwed to the wall."
  end
end

xlate "hang :item on :hook", "place :item :hook"

# The eponymous Cloak of Darkness: when the player takes it to the bar, everything is dark.
# We don't handle wearing it different from carrying it. 

cloak = make Item,
  :name => "a velvet cloak",
  :description => "A handsome cloak, of velvet trimmed with satin, and slightly splattered with raindrops. Its blackness is so deep that it almost seems to suck light from the room.", 
  :synonyms => "dark black satin"


# Stop the player from dropping the cloak except in the cloak room.

respond :drop, Query::Children.new(cloak) do |actor, message|
  if actor.parent != cloakroom then 
      actor.tell "This isn't the best place to leave a smart cloak lying around."
  else
    actor.proceed
  end
end


# The bar. If the player is wearing the cloak, it's dark and the player can't see a thing. 
# Otherwise, the player can see the sawdust on the floor.

bar = make Room, 
  :name => "Foyer Bar", 
  :description => "The bar, much rougher than you'd have guessed after the opulence of the foyer to the north, is completely empty. There seems to be some sort of message scrawled in the sawdust on the floor."
bar.dark = true
foyer.connect bar, "south"


# There's a message in the sawdust. If the player does things in the dark, the message is destroyed.
# We track this using a player.session[:disturbed] boolean.

message = make Scenery,
  :name => "message",
  :description => "", # this is handled in a specific respond :look 
  :parent => bar,
  :synonyms => "scrawl scrawled sawdust dust"

respond :look, Query::Siblings.new(message) do |actor, message|
  if actor.session[:disturbed] then 
    conclude actor, :you_have_lost
  else
    conclude actor, :you_have_won
  end
end

xlate "read :message", "look :message"

# Customize the :has_enough_light rule to check if the player has the cloak.

assert_action :has_enough_light do |actor, action|
  if cloak.parent == actor
    bar.dark = true
  else
    bar.dark = false
  end
  if actor.room.dark?
    if action == :go
      true
    elsif action == :look
      actor.tell "It's too dark in here."
      false
    else
      actor.tell "Uh oh, you're wandering around in the dark!"
      actor.session[:disturbed] = true
      false
    end
  else
    true
  end
end

# The player

introduction do |player|
  player.tell "Hurrying through the rainswept November night, you're glad to see the bright lights of the Opera House. It's surprising that there aren't more people about but, hey, what do you expect in a cheap demo game...?"
    player.parent = foyer
    cloak.parent = player
    player.session[:disturbed] = false
    player.perform "look"
end

# Two different endings

conclusion :you_have_won do |actor|
  actor.tell "The message, neatly marked in the sawdust, reads..."
  actor.tell "*** You have won ***"
end

conclusion :you_have_lost do |actor|
  actor.tell "The message has been carelessly trampled, making it difficult to read. You can just distinguish the words..."
  actor.tell "*** You have lost ***"
end
